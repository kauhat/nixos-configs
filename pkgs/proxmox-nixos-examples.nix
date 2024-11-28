{
  pkgs,
  nixos-generators,
  ...
}: let
  proxomx-lxc-base = nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    format = "proxmox-lxc";

    modules = [
      ./hosts/lxc-http.nix
    ];
  };

  proxomx-vm-base = nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    format = "proxmox";
    modules = [
      ./hosts/vm-http.nix
    ];
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "proxmox-configurations";
    version = "1.0";
    description = "Proxmox LXC and VM configurations";

    buildInputs = [
      nixos-generators
    ];

    packages = [
      proxomx-lxc-base
      proxomx-vm-base
    ];
  }
