{
  pkgs,
  self,
  ...
}: let
  vmware = pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    format = "vmware";

    modules = [
      # you can include your own nixos configuration here, i.e.
      ./hosts/vmware-test/configuration.nix
    ];

    # optional arguments:
    # explicit pkgs and lib:
    # pkgs = pkgs.legacyPackages.x86_64-linux;
    # lib = pkgs.legacyPackages.x86_64-linux.lib;
    # additional arguments to pass to modules:
    # specialArgs = { myExtraArg = "foobar"; };

    # you can also define your own custom formats
    # customFormats = { "myFormat" = <myFormatModule>; ... };
    # format = "myFormat";
  };

  virtualbox = pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    format = "virtualbox";
  };

  hyperv = pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    format = "hyperv";

    modules = [
      ./hosts/hyperv-test/configuration.nix
    ];
  };
in {
  vmware-image = vmware.config.system.build.vm.diskImage;
  virtualbox-image = virtualbox.config.system.build.vm.diskImage;
  hyperv-image = hyperv.config.system.build.vm.diskImage;
}
