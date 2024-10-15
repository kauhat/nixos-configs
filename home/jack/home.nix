# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  corePackages = with pkgs; [
    procs
    htop

    unzip
    zip

    tmux
    # neovim

    fd
    fzf
    ripgrep
    jq
    restic

    alejandra
    nixfmt
    nil
    nox
  ];
  shellPackages = with pkgs; [zsh direnv starship];
  devPackages = with pkgs; [
    delta
    tokei
    devbox
  ];
  netPackages = with pkgs; [
    wget
    dig
    dogdns
    xh
    rclone

    iftop
    bandwhich

    # cloudflared
    # wrangler
  ];
  blingPackages = with pkgs; [
    bottom
    tealdeer
    dust
    #zellij
    #byobu
    #mosh
  ];
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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

  home.packages =
    corePackages
    ++ shellPackages
    ++ netPackages
    ++ devPackages
    ++ blingPackages;

  programs.home-manager.enable = true;

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

  programs.neovim.enable = true;

  programs.gh = {
    enable = true;
    settings = {git_protocol = "ssh";};
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bat = {
    enable = true;
    config = {
      tabs = "4";
      theme = "Dracula";
    };
  };

  # Terminal bling
  programs.bash = {
    enable = false;
    # initExtra = ''
    #   # Auto launch zsh.
    #   if [ "$\{ZSH_VERSION:-unset}" = "unset" ] ; then
    #       export SHELL=/bin/zsh
    #       exec /bin/zsh -l
    #   fi
    # '';
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # TODO: Add rclone config to Nix config.
  # TODO: Load secrets from Bitwarden CLI?
  systemd.user.services.mount-drive-notes = {
    Unit = {
      Description = "Mount Google Drive notes";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p %h/Notes";
      ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/rclone.conf --vfs-cache-mode full --vfs-cache-max-age 96h --vfs-cache-max-size 4G --ignore-checksum mount \"drive_notes:\" \"Notes\"";
      ExecStop="/bin/fusermount -u %h/Notes/%i";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
