{
  description = "Jack's public Nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    #
    nixosModules = {
      base-lxc = ./hosts/base-lxc.nix;
    };

    # NixOS configurations
    #
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = attrs;
        modules = [
          ./hosts/workstation.nix
        ];
      };
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
            devbox.defaultPackage.${system}
          ];

          # packages = [
          #   pkgs.rsync
          #   pkgs.nixos-rebuild
          #   ragenix.packages."${system}".ragenix
          # ];
        };
      }
    );
  };
}
