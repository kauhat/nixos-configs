{
  description = "Jack's public Nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generators
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Devbox
    devbox = {
      url = "github:jetify-com/devbox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-generators,
    devbox,
    ...
  } @ attrs: let
    inherit (self) outputs;

    # Define the architectures for which we'll build packages and configurations.
    supportedSystems = [
      "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
    ];

    # Helper function to create an attribute set that applies to all supported systems.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    # Expose the supportedSystems list
    supportedSystems = supportedSystems;

    #
    packages = forAllSystems (system:
      import ./pkgs ({
          pkgs = nixpkgs.legacyPackages.${system};
        }
        // attrs));

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    #
    # apps = forAllSystems (system: {
    #   proxmox-templates = {
    #     type = "app";
    #     program = "${nixpkgs.writeShellScript "run-proxmox-examples" ''
    #       echo "This is a collection of Proxmox examples.  See the packages output for the actual configurations."
    #       echo "You can find the generated configurations in the packages output."
    #       echo "To use them, import this flake and access the 'proxmox-templates' package."
    #     ''}";
    #   };
    #   toolbx-image = {
    #     type = "app";
    #     program = "${nixpkgs.writeShellScript "run-toolbx-image" ''
    #       echo "This will build a docker image based on your workstation configuration."
    #       echo "You can find the image definition in the packages output."
    #       echo "To use it, import this flake and access the 'toolbx-image' package."
    #     ''}";
    #   };
    # });

    #
    # overlays = {
    #   default = final: prev: {
    #     jackPublic = {
    #       proxmox-templates = self.packages.x86_64-linux.proxmox-templates;
    #       toolbx-image = self.packages.x86_64-linux.toolbx-image;
    #     };
    #   };
    # };

    #
    nixosModules = {
      template-lxc = import ./hosts/template-lxc.nix;
    };

    # NixOS configurations
    #
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # default = nixpkgs.lib.nixosSystem {
      #   specialArgs = attrs;
      #   modules = [
      #     ./hosts/base.nix
      #   ];
      # };
    };

    # Home-manager configurations
    #
    # Available through 'home-manager --flake .#jack'
    homeConfigurations = {
      "jack" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [
          ./home/jack/base.nix
        ];
      };

      "jack-workstation" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [
          ./home/jack/extended.nix
        ];
      };

      "jack-toolbox" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [
          ./home/jack/extended.nix
          {
            home.homeDirectory = "/home/jack/Toolbox";
          }
        ];
      };

      "jack-arm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = attrs;
        modules = [
          ./home/jack/extended.nix
        ];
      };

      # FIXME replace with your username@hostname
      "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [];
      };
    };

    # Development shells
    #
    # Available through 'nix develop'
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            wget
            bat
            restic
          ];

          packages = [
            # devbox
            # devbox.defaultPackage.${system}
            #   pkgs.rsync
            #   pkgs.nixos-rebuild
            #   ragenix.packages."${system}".ragenix
          ];
        };
      }
    );
  };
}
