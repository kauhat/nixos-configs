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
  #
  # The result is copied into the image as plain files rather than linked
  # from the store. The store lives in a volume that is shared between the
  # containers and hides the store of the image, so a link into it breaks
  # as soon as the image is rebuilt and the store path changes. The
  # container setup also has to add the host user to them, which needs
  # them to be writable.
  baseEtc = pkgs.runCommand "fedora-etc-with-nixbld" {nativeBuildInputs = [pkgs.jq];} ''
    mkdir -p $out/etc
    tar -xf ${fedoraToolbox} manifest.json
    layer=$(jq -r '.[0].Layers[0]' manifest.json)
    tar -xf ${fedoraToolbox} -O "$layer" | tar -xf - -C $out etc/passwd etc/group

    # The nix daemon refuses to build anything unless the build users group
    # has members: "error: the build users group 'nixbld' has no members".
    # Listing the users as members of the group is what the nix daemon
    # looks for, so the group needs the member list, not just the users
    # in the passwd file.
    members="$out/etc/nixbld-members"
    : > "$members"
    for i in $(seq 1 32); do
      echo "nixbld''${i}:x:$((30000 + i)):30000:Nix build user:/var/empty:/noshell" >> $out/etc/passwd
      printf 'nixbld%d,' "$i" >> "$members"
    done
    sed -i 's/,$//' "$members"
    echo "nixbld:x:30000:$(cat "$members")" >> $out/etc/group
    rm "$members"
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
      ]);

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

      # --- /etc/passwd and /etc/group ---
      # The contents of the store are linked into the image, so these two
      # would be links into the store. The store is a volume that is shared
      # between the containers and hides the store of the image, so such a
      # link dangles as soon as the image is rebuilt and the store path
      # changes. The container setup also adds the host user to them, which
      # needs them to be writable. Write them out as plain files instead.
      rm -f ./etc/passwd ./etc/group
      cat ${baseEtc}/etc/passwd > ./etc/passwd
      cat ${baseEtc}/etc/group > ./etc/group
      chmod 644 ./etc/passwd ./etc/group

      # --- nix-daemon ---
      # systemd only finds units that live in one of its unit search paths
      # (/etc/systemd/system, /run/systemd/system, /usr/lib/systemd/system,
      # ...). The symlinks in the .wants directories below only tell systemd
      # that the unit should be started, they do not make it loadable, so
      # "systemctl enable nix-daemon.service" fails with "unit does not
      # exist" and the distrobox init hook aborts the container setup.
      # Put the unit files in /usr/lib/systemd/system as well, so that
      # systemd can load them and the init hook succeeds.
      mkdir -p ./etc/systemd/system/multi-user.target.wants
      mkdir -p ./etc/systemd/system/sockets.target.wants
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.service ./etc/systemd/system/multi-user.target.wants/nix-daemon.service
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.socket ./etc/systemd/system/sockets.target.wants/nix-daemon.socket
      mkdir -p ./usr/lib/systemd/system
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.service ./usr/lib/systemd/system/nix-daemon.service
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.socket ./usr/lib/systemd/system/nix-daemon.socket
    '';

    config = {
      Cmd = ["/usr/lib/systemd/systemd"];
      Env = [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ];
    };
  }
