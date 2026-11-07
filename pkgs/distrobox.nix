{pkgs, ...}:
# Nix-native Distrobox image with systemd and Nix daemon
pkgs.dockerTools.streamLayeredImage {
  name = "local/nix-distrobox";
  tag = "latest";

  # Replaces your 'dnf install' block
  contents = with pkgs; [
    bashInteractive
    coreutils
    shadow
    sudo
    curl
    git
    fish
    zsh
    systemd
    dbus
    pipewire
    libsecret
    kdePackages.kwallet
    kdePackages.kwalletmanager
    nix
    # Distrobox essentials not explicitly in your dnf list but required
    findutils
    util-linux
    glibc
    procps
    tzdata
    mount
  ];

  fakeRootCommands = ''
    # Set up essential FHS directories Distrobox expects to mount into
    mkdir -p ./bin ./usr/bin ./sbin ./etc ./tmp ./var/tmp ./usr/lib ./usr/lib64
    mkdir -p ./nix/var/nix/daemon-socket

    # FHS symlinks for Distrobox init script and Systemd entrypoint
    ln -sf ${pkgs.bashInteractive}/bin/bash ./bin/bash
    ln -sf ${pkgs.bashInteractive}/bin/bash ./bin/sh
    ln -sf ${pkgs.coreutils}/bin/env ./usr/bin/env
    ln -sf ${pkgs.systemd}/lib/systemd/systemd ./sbin/init

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
