{
  lib,
  pkgs,
  ...
}: let
  # The distrobox entrypoint needs a real userland to set the container up:
  # PAM for sudo, shadow tools to create the user, systemd units to boot.
  # Fedora's toolbox image has all of that, so the Nix parts are layered on
  # top of it instead of trying to rebuild a distribution from scratch.
  fedoraToolbox = pkgs.dockerTools.pullImage {
    imageName = "quay.io/fedora/fedora-toolbox";
    imageDigest = "sha256:3d8c46e803fd184e9318ee90d4e6f1ad0b591a1c49f4de683d4f8748c0b95c30";
    outputHash = "0ni43sag0mgjsalk0a0pzglrcqhsvbxakw9g35q7l1dwivmp87lq";
    outputHashAlgo = "sha256";
  };

  # The nix daemon builds as the nixbld users, so the image needs them. A
  # file in a later layer replaces the same file from the base image, so
  # writing /etc/passwd here would leave the container without a root user
  # and it could not even start:
  #
  #   unable to find user root: no matching entries in passwd file
  #
  # So take the passwd and group of the base image and add the build users
  # to those.
  baseEtc = pkgs.runCommand "fedora-etc-with-nixbld" {nativeBuildInputs = [pkgs.jq];} ''
    mkdir -p $out/etc
    tar -xf ${fedoraToolbox} manifest.json
    layer=$(jq -r '.[0].Layers[0]' manifest.json)
    tar -xf ${fedoraToolbox} -O "$layer" | tar -xf - -C $out etc/passwd etc/group

    echo "nixbld:x:30000:" >> $out/etc/group
    for i in $(seq 1 32); do
      echo "nixbld''${i}:x:$((30000 + i)):30000:Nix build user:/var/empty:/noshell" >> $out/etc/passwd
    done
  '';
in
  pkgs.dockerTools.streamLayeredImage {
    name = "local/nix-distrobox";
    tag = "latest";

    fromImage = fedoraToolbox;

    contents =
      (with pkgs; [
        kdePackages.kwallet
        kdePackages.kwalletmanager
        libsecret
        nix
        pipewire
      ])
      ++ [baseEtc];

    fakeRootCommands = ''
      # The Nix layers link the binaries of their packages into /bin and /lib,
      # which shadows the /bin -> usr/bin and /lib -> usr/lib symlinks of
      # the Fedora base image. Move them into /usr/bin and /usr/lib and put
      # the symlinks back, or the container ends up without a shell.
      mkdir -p ./usr/bin ./usr/lib
      for f in ./bin/*; do
        target=$(readlink "$f") || continue
        [ -n "$target" ] || continue
        ln -sf "$target" "./usr/bin/$(basename "$f")"
      done
      rm -rf ./bin
      ln -s usr/bin ./bin

      for f in ./lib/*; do
        target=$(readlink "$f") || continue
        [ -n "$target" ] || continue
        ln -sf "$target" "./usr/lib/$(basename "$f")"
      done
      rm -rf ./lib
      ln -s usr/lib ./lib

      # --- Nix ---
      mkdir -p ./nix/store ./nix/var/nix/daemon-socket ./etc/nix
      chmod 777 ./nix/var/nix/daemon-socket

      echo "experimental-features = nix-command flakes" > ./etc/nix/nix.conf
      echo "trusted-users = root @wheel" >> ./etc/nix/nix.conf

      # --- nix-daemon ---
      mkdir -p ./etc/systemd/system/multi-user.target.wants
      mkdir -p ./etc/systemd/system/sockets.target.wants
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.service ./etc/systemd/system/multi-user.target.wants/nix-daemon.service
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.socket ./etc/systemd/system/sockets.target.wants/nix-daemon.socket
    '';

    config = {
      Cmd = ["/usr/lib/systemd/systemd"];
      Env = [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ];
    };
  }
