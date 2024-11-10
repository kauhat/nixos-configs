{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
in {
  # You can import other home-manager modules here
  imports = [
    ./base.nix
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
    devbox # Dev environment manager
    tokei # Count lines of code
    tealdeer # Interactive cheat sheet

    # Networking Tools
    dig # DNS client
    dogdns # DNS client
    hurl # Scriptable HTTP client
    xh # HTTP client

    # Monitoring and Resource Management
    iftop # Bandwidth usage
    bandwhich # Process bandwidth
    bottom # Resource monitor

    # Terminal Multiplexers
    tmux # Terminal multiplexer
    zellij # Productive terminal workspace
    byobu # Terminal window manager
  ];

  programs.zsh = {
    oh-my-zsh = {
      enable = true;
      # theme = "dracula";

      plugins = [
        # Manually installed below...
        #
        # "zsh-aliases-exa"
        # "you-should-use"
        # "fzf-tab"

        "ssh-agent"
        "vscode"

        "fzf"
        "ripgrep"
        "copypath"
        "copyfile"
        "copybuffer"

        "gitfast"
        "git-lfs"
        "gh"

        "ubuntu"
        "docker"

        "rust"

        "yarn"
        "composer"
        "laravel"
        "wp-cli"
      ];
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "190500bf1de6a89416e2a74470d3b5cceab102ba";
          sha256 = "1dipsy0s67fr47ig5559bcp1h5yn8rdjshhs8zsq7j8plvvh99qb";
        };
      }
      # {
      #   name = "zsh-syntax-highlighting";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "zsh-users";
      #     repo = "zsh-syntax-highlighting";
      #     rev = "0.7.1";
      #     sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
      #   };
      # }
      {
        name = "you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          sha256 = "1dipsy0s67fr47ig5559bcp1h5yn8rdjshhs8zsq7j8plvvh99qb";
        };
      }
    ];
  };

  programs.neovim.enable = true;

  programs.gh = {
    enable = true;
    settings = {git_protocol = "ssh";};
  };

  services.mountGdriveNotes.enable = true;
}
