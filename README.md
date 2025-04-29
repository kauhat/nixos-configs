# Jack's personal Nix configurations

This repository contains my Home Manager configs, reusable modules, and some host definitions. This flake is intended to be consumed as an input to another flake, but parts of it can be used directly. Hopefully it'll be helpful to someone. However this is very much a work in progress which is likely to change.

## Repository structure

- `home/`: My Home Manager configurations
- `hosts/`: Includes host-specific configurations
- `modules/`: Reusable NixOS and Home Manager modules
- `pkgs/`: Custom Nix packages

## Usage

### Directly

#### Enter the development shell

```bash
nix develop
```

#### Apply a specific Home Manager configuration

```bash
home-manager switch --flake github:kauhat/nixos-configs#jack-workstation
```

### As an input to another flake

Add this repository to the `inputs` section of your own `flake.nix`:

```nix
# flake.nix
{
    inputs = {
        # ... other inputs ...

        # My public configs.
        jack-public-configs.url = "github:kauhat/nixos-configs";

        nixpkgs.follows = "public-configs/nixpkgs";
    };

    outputs = { self, nixpkgs, home-manager, jack-public-configs, ... } @ inputs: {
        # You can now access outputs from jack-public-configs

        # Example: Use a Home Manager module
        homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = inputs;
            modules = [
                jack-public-configs.homeConfigurations.jack-workstation

                # Import a public module
                # jack-public-configs.homeManagerModules.gdrive-notes-mount

                ./home/your-config-overrides.nix
            ];
        };

        # Example: Use a NixOS module
        # nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
        #   specialArgs = inputs;
        #   modules = [
        #     ./hosts/your-host.nix # Your private host config
        #     jack-public-configs.nixosModules.base-lxc # Import a public module
        #   ];
        # };

        # Example: Access a custom package
        # devShells.x86_64-linux = nixpkgs.lib.mkShell {
        #   packages = [ jack-public-configs.packages.x86_64-linux.some-custom-pkg ];
        # };

        # ... rest of your private flake outputs ...
        };
    };
}
```
