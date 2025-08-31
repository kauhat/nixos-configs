{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  devbox,
  ...
}: let
in {
  # You can import other home-manager modules here
  imports = [
    outputs.nixosModules.base
    ../../modules/home-manager/gdrive-notes-mount.nix
    ../../modules/home-manager/gdrive-notes-sync.nix
  ];

  home.packages = with pkgs; [
    # Backup and Synchronization Tools
    restic # Efficient backup
    rsync # File transfer and sync
    rclone # Cloud file transfer

    # Nix/NixOS
    alejandra # Nix code formatting
    nil # Nix language server

    # Development and Productivity Tools
    tokei # Count lines of code
    tealdeer # Interactive cheat sheet
    devbox.packages.${pkgs.system}.default

    # Networking Tools
    dig # DNS client
    dogdns # DNS client
    hurl # Scriptable HTTP client
    xh # HTTP client

    # Monitoring and Resource Management
    iftop # Bandwidth usage
    bandwhich # Process bandwidth
    bottom # Resource monitor
    isd # Systemd TUI

    # Terminal Multiplexers
    tmux # Terminal multiplexer
    byobu # Terminal window manager
  ];

  programs.zsh = {
    antidote = {
      # theme = "dracula";

      plugins = [
        "ohmyzsh/ohmyzsh path:plugins/vscode"
        "ohmyzsh/ohmyzsh path:plugins/gh"
        "ohmyzsh/ohmyzsh path:plugins/ubuntu"
        "ohmyzsh/ohmyzsh path:plugins/docker"
        "ohmyzsh/ohmyzsh path:plugins/rust"
        "ohmyzsh/ohmyzsh path:plugins/yarn"
        "ohmyzsh/ohmyzsh path:plugins/composer"
        "ohmyzsh/ohmyzsh path:plugins/laravel"
        "ohmyzsh/ohmyzsh path:plugins/wp-cli"
      ];
    };

    plugins = [
      # {
      #   name = "you-should-use";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "MichaelAquilina";
      #     repo = "zsh-you-should-use";
      #     rev = "1.7.3";
      #     sha256 = "1dipsy0s67fr47ig5559bcp1h5yn8rdjshhs8zsq7j8plvvh99qb";
      #   };
      # }
    ];
  };

  programs.zellij = {
    enable = true;
  };

  programs.gh = {
    enable = true;
    settings = {git_protocol = "ssh";};
  };

  services.ssh-agent = {
    enable = true;
  };

  services.gdriveNotesMount = {
    enable = false;
  };

  services.gdriveNotesSync = {
    enable = false;
  };

  services.syncthing = {
    enable = true;
    # group = "jack";
    # user = "jack";
    # dataDir = "/home/jack/Documents";
    # configDir = "/home/jack/Documents/.config/syncthing";
    settings = {
      devices = {
        # "device1" = { id = "DEVICE-ID-GOES-HERE"; };
        # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      folders = {
        "Documents" = {
          path = "/home/jack/Documents";
          # devices = [ "device1" "device2" ];
        };
        "Notes" = {
          path = "/home/jack/Notes";
          # devices = [ "device1" ];
          # ignorePerms = false;
        };
      };
    };
  };
}
