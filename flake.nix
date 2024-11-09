{
  description = "Jack's Nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    ragenix.url = "github:yaxitech/ragenix";

    # Generators
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    # packages = forAllSystems (system:   ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # FIXME replace with your hostname
      workstation = nixpkgs.lib.nixosSystem {
        specialArgs = attrs;
        modules = [
          # > Our main nixos configuration file <
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

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      jack = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = attrs;
        modules = [
          # > Our main home-manager configuration file <
          ./home/jack/home.nix
        ];
      };

      jack-full = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = attrs;
        modules = [
          # > Our main home-manager configuration file <
          ./home/jack/home.nix
          ./modules/mount-gdrive-notes.nix
        ];
      };
    };

    packages.x86_64-linux = {
      proxomx-lxc-minecraft = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "proxmox-lxc";

        modules = [
          ./hosts/lxc-minecraft.nix
        ];
      };

      proxomx-lxc-http = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "proxmox-lxc";

        modules = [
          ./hosts/lxc-http.nix
        ];
      };

      proxomx-vm-http = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "proxmox";
        modules = [
          ./hosts/vm-http.nix
        ];
      };
    };

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
