{
  description = "Jack's public Nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manage.url = "github:nix-community/home-manager/release-25.11";
    home-manage.inputs.nixpkgs.follows = "nixpkgs";

    # Devbox
    devbox.url = "github:jetify-com/devbox";
    devbox.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    devbox,
    ...
  } @ attrs: let
    supportedSystems = [
      "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
    ];

    # Helper function to create an attribute set that applies to all supported systems.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    # Expose the supportedSystems list
    inherit supportedSystems;

    #
    packages = forAllSystems (system:
      import ./pkgs ({
          pkgs = nixpkgs.legacyPackages.${system};
        }
        // attrs));

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    home-manager = forAllSystems (system: home-manager.packages.${system}.home-manager);

    tests = {
      basic-test = nixpkgs.lib.makeTest {
        name = "basic-test";
        system = "x86_64-linux";
        expectedToFail = false;
        phases = ''
          buildPhase() {
            echo "Running test..."
            # Add your test commands here
          }
        '';
      };
    };

    # NixOS modules
    #
    nixosModules = {
      base = import ./modules/nixos/base.nix;
      base-lxc = import ./modules/nixos/base-lxc.nix;
      base-vm = import ./modules/nixos/base-vm.nix;
      users = import ./modules/nixos/users.nix;
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

    # Home-manager modules
    #
    homeModules = {
      base = import ./home/jack/base.nix;
      extended = import ./home/jack/extended.nix;
    };

    # Home-manager configurations
    #
    # Available through 'home-manager --flake .#jack'
    homeConfigurations = {
      "jack" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [
          self.homeModules.base
        ];
      };

      "jack-workstation" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [
          self.homeModules.extended
        ];
      };

      "jack-toolbox" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = attrs;
        modules = [
          self.homeModules.extended
          {
            home.homeDirectory = nixpkgs.lib.mkForce "/home/jack/Toolbox";
          }
        ];
      };

      "jack-arm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = attrs;
        modules = [
          self.homeModules.extended
        ];
      };

      # "jack-minimal" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #   extraSpecialArgs = attrs;
      #   modules = [
      #     self.homeModules.minimal
      #   ];
      # };

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
          buildInputs = with pkgs; [
            home-manager.packages.${system}.home-manager
            direnv
            wget
            bat
            restic
          ];

          packages = [
            # devbox
            # devbox.defaultPackage.${system}
          ];
        };
      }
    );

    # Other configurations...
  };
}
