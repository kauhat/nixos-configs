{
  description = "Jack's public Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    ...
  }: let
    supportedSystems = [
      "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
    ];
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = supportedSystems;

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        coreLib = import ./pkgs/lib.nix {inherit pkgs;};
        corePackages = import ./pkgs/core.nix {inherit pkgs;};
        localPackages = import ./pkgs {inherit pkgs;};
      in {
        formatter = pkgs.alejandra;

        # Packages that `nix flake check` builds
        packages = corePackages;

        # Heavy packages (e.g. disk images) that `nix flake check` skips.
        # Build explicitly with `nix build .#<name>`.
        legacyPackages = localPackages;

        # Development shells
        devShells.default = pkgs.mkShell {
          buildInputs = [
            home-manager.packages.${system}.home-manager
            pkgs.yamllint
            pkgs.kube-linter
            pkgs.prettier
          ];
        };
      };

      # Top-level flake attributes (not per-system)
      flake = {
        supportedSystems = supportedSystems;

        home-manager = home-manager.packages.x86_64-linux.home-manager;

        lib = {
          mkLib = pkgs: import ./pkgs/lib {inherit pkgs;};
        };

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
        nixosModules = {
          base = import ./modules/nixos/base.nix;
          base-lxc = import ./modules/nixos/base-lxc.nix;
          base-vm = import ./modules/nixos/base-vm.nix;
          users = import ./modules/nixos/users.nix;
        };

        # NixOS configurations (currently empty)
        nixosConfigurations = {};

        # Home-manager modules
        homeModules = {
          base = import ./home/jack/base.nix;
          extended = import ./home/jack/extended.nix;
        };

        # Home-manager configurations
        homeConfigurations = {
          "jack" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = inputs;
            modules = [
              self.homeModules.base
            ];
          };

          "jack-workstation" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = inputs;
            modules = [
              self.homeModules.extended
            ];
          };

          "jack-toolbox" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = inputs;
            modules = [
              self.homeModules.extended
              {
                home.homeDirectory = nixpkgs.lib.mkForce "/home/jack/Toolbox";
              }
            ];
          };

          # "jack@penguin" = home-manager.lib.homeManagerConfiguration {
          #   pkgs = nixpkgs.legacyPackages.aarch64-linux;
          #   extraSpecialArgs = inputs;
          #   modules = [
          #     self.homeModules.extended
          #   ];
          # };

          # "jack-minimal" = home-manager.lib.homeManagerConfiguration {
          #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
          #   extraSpecialArgs = inputs;
          #   modules = [
          #     self.homeModules.minimal
          #   ];
          # };
        };
      };
    };
}
