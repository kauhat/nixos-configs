# FIXME: Build fresh containers and VMs for my server hosts.
{
  pkgs,
  nixos-generators,
  ...
}: let
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
in
  pkgs.stdenv.mkDerivation {
    pname = "proxmox-configurations";
    version = "1.0";
    description = "Proxmox LXC and VM configurations";

    buildInputs = [
      nixos-generators
    ];

    packages = [
      proxomx-lxc-minecraft
      proxomx-lxc-http
      proxomx-vm-http
    ];
  }
