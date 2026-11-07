{
  lib,
  pkgs,
  ...
}: let
  # The distrobox entrypoint runs before any shell is set up and needs a
  # regular userland on PATH, so these are linked into /usr/bin.
  baseTools = with pkgs; [
    coreutils
    diffutils
    file
    findutils
    gawk
    getent
    glibc.bin
    gnugrep
    gnused
    gnutar
    gzip
    inetutils
    iputils
    lsof
    rsync
    shadow
    sudo
    systemd
    tree
    unzip
    util-linux
    which
    wget
    xz
  ];
in
  pkgs.dockerTools.streamLayeredImage {
    name = "local/nix-distrobox";
    tag = "latest";

    contents =
      (with pkgs; [
        bashInteractive
        curl
        dbus
        fish
        git
        glibc
        kdePackages.kwallet
        kdePackages.kwalletmanager
        libsecret
        mount
        nix
        pipewire
        procps
        systemd
        tzdata
        util-linux
        zsh
      ])
      ++ baseTools;

    fakeRootCommands = ''
      # Set up essential FHS directories Distrobox expects to mount into
      mkdir -p ./bin ./usr/bin ./sbin ./etc ./tmp ./var/tmp ./usr/lib ./usr/lib64
      mkdir -p ./nix/var/nix/daemon-socket

      # FHS symlinks for Distrobox init script and Systemd entrypoint
      ln -sf ${pkgs.bashInteractive}/bin/bash ./bin/bash
      ln -sf ${pkgs.bashInteractive}/bin/bash ./bin/sh
      ln -sf ${pkgs.coreutils}/bin/env ./usr/bin/env
      ln -sf ${pkgs.systemd}/lib/systemd/systemd ./sbin/init

      # Link the base tools into /usr/bin. Distrobox rebuilds the container
      # PATH from the host, so the image cannot rely on its own PATH here:
      # the entrypoint needs grep, sed, awk, mount and friends to be found.
      for tool in ${lib.concatStringsSep " " baseTools}; do
        for bin in "$tool"/bin/*; do
          [ -e "$bin" ] && ln -sf "$bin" ./usr/bin/
        done
      done

      # Pre-create groups required by your distrobox.ini hooks and Nix daemon
      echo 'root:x:0:' > ./etc/group
      echo 'wheel:x:10:root' >> ./etc/group
      echo 'video:x:39:root' >> ./etc/group
      echo 'render:x:399:root' >> ./etc/group
      echo 'root:x:0:0:root:/root:/bin/bash' > ./etc/passwd

      # Replaces your /etc/nix/nix.conf generation
      chmod 777 ./nix/var/nix/daemon-socket
      mkdir -p ./etc/nix
      echo "experimental-features = nix-command flakes" > ./etc/nix/nix.conf
      echo "trusted-users = root @wheel" >> ./etc/nix/nix.conf

      # Replaces your 'systemctl enable nix-daemon'
      mkdir -p ./etc/systemd/system/multi-user.target.wants
      mkdir -p ./etc/systemd/system/sockets.target.wants
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.service ./etc/systemd/system/multi-user.target.wants/nix-daemon.service
      ln -sf ${pkgs.nix}/lib/systemd/system/nix-daemon.socket ./etc/systemd/system/sockets.target.wants/nix-daemon.socket
    '';

    config = {
      Cmd = ["/sbin/init"];
      Env = [
        "PATH=/nix/var/nix/profiles/default/bin:/bin:/usr/bin:/sbin"
      ];
    };
  }
