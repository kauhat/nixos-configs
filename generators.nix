{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-generators,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux = {
      vmware = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "vmware";

        modules = [
          # you can include your own nixos configuration here, i.e.
          ./hosts/vmware-test/configuration.nix
        ];

        # optional arguments:
        # explicit nixpkgs and lib:
        # pkgs = nixpkgs.legacyPackages.x86_64-linux;
        # lib = nixpkgs.legacyPackages.x86_64-linux.lib;
        # additional arguments to pass to modules:
        # specialArgs = { myExtraArg = "foobar"; };

        # you can also define your own custom formats
        # customFormats = { "myFormat" = <myFormatModule>; ... };
        # format = "myFormat";
      };

      # vbox = nixos-generators.nixosGenerate {
      #   system = "x86_64-linux";
      #   format = "virtualbox";
      # };
    };

    vmwareIso = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "iso";

      modules = [
        ./hosts/vmware-test/configuration.nix
      ];
    };

    hyperv = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "hyperv";

      modules = [
        ./hosts/hyperv-test/configuration.nix
      ];
    };

    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [
        pkgs.open-vm-tools
        pkgs.cowsay
      ];
    };
  };
}
