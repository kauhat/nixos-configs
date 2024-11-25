{
  description = "Jack's public Nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Generators
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ragenix.url = "github:yaxitech/ragenix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-generators,
    ragenix,
    ...
  } @ attrs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # configHelpers.systems = systems;
    # configHelpers.forAllSystems = forAllSystems;

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

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

      lxc-http = nixpkgs.lib.nixosSystem {
        specialArgs = attrs;
        system = "x86_64-linux";
        modules = [
          ./hosts/lxc-http.nix
        ];
      };

      lxc-minecraft = nixpkgs.lib.nixosSystem {
        specialArgs = attrs;
        system = "x86_64-linux";
        modules = [
          ./hosts/lxc-minecraft.nix
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

      # FIXME replace with your username@hostname
      "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [];
      };
    };

    # Development shells
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          packages = [
            pkgs.rsync
            pkgs.nixos-rebuild
            ragenix.packages."${system}".ragenix
          ];
        };
      }
    );
  };
}
