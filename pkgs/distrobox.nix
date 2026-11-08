{
  lib,
  pkgs,
  name ? "ghcr.io/kauhat/distrobox-nix",
  tag ? "latest",
  ...
}:
pkgs.dockerTools.buildLayeredImage {
  inherit name tag;

  contents = with pkgs; [
    # Core Distrobox requirements & init tools
    bashInteractive
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    util-linux
    shadow
    sudo
    systemd
    dbus
    pam
    nix

    # User utilities & libraries
    git
    curl
    fish
    zsh
    pipewire
    libsecret
    kdePackages.kwallet
    kdePackages.kwalletmanager
  ];

  fakeRootCommands = ''
        # 1. Ensure essential relative target directories exist
        mkdir -p ./etc ./etc/pam.d ./bin ./usr/bin ./usr/lib ./usr/lib/systemd ./var/log ./var/tmp ./tmp

        # 2. Run shadow setup for base /etc/passwd and /etc/group files
        ${pkgs.dockerTools.shadowSetup}

        # Pre-create essential groups expected by systemd, nix, and distrobox
        echo "wheel:x:10:root" >> ./etc/group
        echo "audio:x:63:" >> ./etc/group
        echo "video:x:44:" >> ./etc/group
        echo "render:x:109:" >> ./etc/group

        # 3. Add nixbld build users for daemon builds
        MEMBERS=""
        for i in $(seq 1 32); do
          echo "nixbld$i:x:$((30000 + i)):30000:Nix build user:/var/empty:${pkgs.shadow}/bin/nologin" >> ./etc/passwd
          MEMBERS="nixbld$i,$MEMBERS"
        done
        MEMBERS=$(echo "$MEMBERS" | sed 's/,$//')
        echo "nixbld:x:30000:$MEMBERS" >> ./etc/group

        # 4. Create FHS layout symlinks for Distrobox host integrations
        ln -sf ${pkgs.bashInteractive}/bin/sh ./bin/sh
        ln -sf ${pkgs.coreutils}/bin/env ./usr/bin/env
        ln -sf ${pkgs.systemd}/lib/systemd/systemd ./usr/lib/systemd/systemd

        # Provide PAM setup so sudo works when Distrobox maps the host user
        cat <<EOF > ./etc/pam.d/sudo
    auth     sufficient pam_rootok.so
    auth     required   pam_unix.so
    account  required   pam_unix.so
    session  required   pam_unix.so
    EOF

        # 5. Systemd units for nix-daemon
        mkdir -p ./usr/lib/systemd/system ./etc/systemd/system/multi-user.target.wants ./etc/systemd/system/sockets.target.wants
        cp -f ${pkgs.nix}/lib/systemd/system/nix-daemon.service ./usr/lib/systemd/system/nix-daemon.service
        cp -f ${pkgs.nix}/lib/systemd/system/nix-daemon.socket ./usr/lib/systemd/system/nix-daemon.socket
        ln -sf /usr/lib/systemd/system/nix-daemon.service ./etc/systemd/system/multi-user.target.wants/nix-daemon.service
        ln -sf /usr/lib/systemd/system/nix-daemon.socket ./etc/systemd/system/sockets.target.wants/nix-daemon.socket

        # 6. Nix daemon configuration
        mkdir -p ./nix/var/nix/daemon-socket ./etc/nix
        chmod 777 ./nix/var/nix/daemon-socket
        cat <<EOF > ./etc/nix/nix.conf
    experimental-features = nix-command flakes
    trusted-users = root @wheel
    build-users-group = nixbld
    EOF

        # 7. Host GPU loader path hooks for Distrobox
        mkdir -p ./etc/ld.so.conf.d
        echo "/usr/lib64" > ./etc/ld.so.conf.d/nvidia-distrobox.conf
        echo "/usr/lib/x86_64-linux-gnu" >> ./etc/ld.so.conf.d/nvidia-distrobox.conf
  '';

  config = {
    Cmd = ["/usr/lib/systemd/systemd"];
    Env = [
      "PATH=/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ];
  };
}
