#
# very sloppy, doesn't work
#
{
  lib,
  pkgs,
  name ? "ghcr.io/kauhat/nix-distrobox",
  tag ? "latest",
  ...
}: let
  fedoraToolbox = pkgs.dockerTools.pullImage {
    imageName = "quay.io/fedora/fedora-toolbox";
    imageDigest = "sha256:e9fbbc53d58a88e2c931fe8e4a562e6d8cc2b680773bd7b4806d70797e9da7b1";
    hash = "sha256-NHjcz+WpKi+sefXdh52yHXzAh1eG5VLJITORIKX7pu8=";
    finalImageName = "quay.io/fedora/fedora-toolbox";
    finalImageTag = "latest";
  };
in
  pkgs.dockerTools.buildImage {
    inherit name tag;

    # IMPORTANT: keep fedora base
    fromImage = fedoraToolbox;
    diskSize = 4096;
    # compressImage = false;

    # overlay nix packages and hope for the best
    contents = with pkgs; [
      # Core Distrobox requirements & init tools
      # bashInteractive
      # coreutils
      # findutils
      # gnugrep
      # gnused
      # gawk
      # util-linux
      # shadow
      sudo
      systemd
      dbus
      # pam
      nix

      # User utilities & libraries
      # git
      # curl
      # fish
      # zsh
      # pipewire
      # libsecret
      # kdePackages.kwallet
      # kdePackages.kwalletmanager
    ];

    runAsRoot = ''
      #!${pkgs.stdenv.shell}

      export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

      mkdir -p /etc/systemd/system/multi-user.target.wants /etc/systemd/system/sockets.target.wants
      ln -sf /usr/lib/systemd/system/nix-daemon.service /etc/systemd/system/multi-user.target.wants/nix-daemon.service
      ln -sf /usr/lib/systemd/system/nix-daemon.socket /etc/systemd/system/sockets.target.wants/nix-daemon.socket

      mkdir -p /etc/nix
      echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
      echo "trusted-users = root @wheel" >> /etc/nix/nix.conf

      groupadd -f wheel
      mkdir -p /nix/var/nix/daemon-socket
      chmod 777 /nix/var/nix/daemon-socket

      mkdir -p /etc/ld.so.conf.d
      echo "/usr/lib64" > /etc/ld.so.conf.d/nvidia-distrobox.conf
    '';

    # config = {
    #   Cmd = ["/usr/lib/systemd/systemd"];
    #   Env = [
    #     "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    #   ];
    # };
  }
