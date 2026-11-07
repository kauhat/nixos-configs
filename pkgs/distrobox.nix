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
in
  pkgs.dockerTools.streamLayeredImage {
    name = "local/nix-distrobox";
    tag = "latest";

    fromImage = fedoraToolbox;

    contents = with pkgs; [
      kdePackages.kwallet
      kdePackages.kwalletmanager
      libsecret
      nix
      pipewire
    ];

    fakeRootCommands = ''
      # --- Nix ---
      mkdir -p ./nix/store ./nix/var/nix/daemon-socket ./etc/nix
      chmod 777 ./nix/var/nix/daemon-socket

      echo "experimental-features = nix-command flakes" > ./etc/nix/nix.conf
      echo "trusted-users = root @wheel" >> ./etc/nix/nix.conf

      # The nix daemon builds as these users, the same ids NixOS uses.
      echo "nixbld:x:30000:" >> ./etc/group
      for i in $(seq 1 32); do
        echo "nixbld''${i}:x:$((30000 + i)):30000:Nix build user:/var/empty:/noshell" >> ./etc/passwd
      done

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
