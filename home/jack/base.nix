# This is your home-manager configuration file.
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
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../../modules/home-mount-gdrive-notes.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # outputs.overlays.additions
      # outputs.overlays.modifications
      # outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "jack";
    homeDirectory = "/home/jack";
  };

  home.packages = with pkgs; [
    # Monitoring and resource management
    procs # Replacement for `ps`
    htop # Interactive viewer
    btop # Resource monitor
    bottom # Terminal-based monitor
    dust # Disk usage tool
    fastfetch # System info display

    # File management and compression
    unzip # Extract files
    zip # Create compressed files
    fd # Alternative to `find`
    fzf # Fuzzy finder

    # Text processing and utilities
    ripgrep # Regex search tool
    jq # JSON processor
    delta # Syntax-highlighting pager

    # Shell and environment management
    zsh # Interactive shell
    starship # Customizable prompt
    direnv # Setup directory env vars

    # Networking tools
    wget # HTTP downloads

    # Remote Access
    mosh # Mobile shell
  ];

  programs.home-manager.enable = true;

  programs.bash = {
    enable = false;
    initExtra = ''
      # # Auto launch zsh.
      # if [ "$\{ZSH_VERSION:-unset}" = "unset" ] ; then
      #     export SHELL=/bin/zsh
      #     exec /bin/zsh -l
      # fi
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.extended = true;

    # initExtra = ''
    #   if [ -e ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh ]; then
    #     . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
    #   fi
    # '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.bat = {
    enable = true;
    config = {
      tabs = "4";
      theme = "Dracula";
    };
  };

  programs.git = {
    enable = true;
    userName = "Jack Fletcher";
    userEmail = "jackowenfletcher@gmail.com";

    # aliases = {
    #   dotfiles = "!git -c status.showUntrackedFiles=no --git-dir=$DOTFILES/.git --work-tree=$HOME";
    # };

    lfs = {enable = true;};

    delta = {
      enable = true;
      options = {
        pager = "bat";
        dark = true;
        navigate = true;
        syntax-theme = "Dracula";
      };
    };

    extraConfig = {
      core = {editor = "nvim";};
      color = {ui = true;};
      push = {default = "simple";};
      pull = {ff = "only";};
    };

    ignores = [
      ".vscode/**"

      # Direnv Files
      ".direnv"
      ".envrc"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    extraConfig = ''
      # Host proxmox
      #   HostName 192.168.1.69
      #   User root
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}