# Build some template LXC and VM images with my base NixOS install.
# The output files of this package are intended to be uploaded to my
# proxmox cluster.
#
# e.g. at:
# /tank/templates/template/cache/
# /tank/isos/template/iso/
#
{
  pkgs,
  self,
  ...
}: let
  proxmox-lxc-base = pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    format = "proxmox-lxc";

    modules = [
      self.outputs.nixosModules.base
      self.outputs.nixosModules.base-lxc
    ];
  };

  proxmox-lxc-base-iso = proxmox-lxc-base.config.system.build.images.iso;

  proxmox-vm-base = pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    format = "proxmox";

    modules = [
      self.outputs.nixosModules.base
      self.outputs.nixosModules.base-vm
    ];
  };

  proxmox-vm-base-iso = proxmox-vm-base.config.system.build.images.iso;
in {
  lxc-base-iso = proxmox-lxc-base-iso;
  vm-base-iso = proxmox-vm-base-iso;
}
# pkgs.stdenv.mkDerivation {
#   pname = "proxmox-configurations";
#   version = "1.0";
#   description = "Proxmox LXC and VM configurations";
#   src = null;
#   dontUnpack = true;
#   dontStrip = true;
#   buildInputs = [
#     proxmox-lxc-base-iso
#     proxmox-vm-base-iso
#   ];
#   installPhase = ''
#     mkdir -p $out/lxc
#     ln -s ${proxmox-lxc-base-iso} $out/lxc/base-lxc.iso
#     mkdir -p $out/vm
#     ln -s ${proxmox-vm-base-iso} $out/vm/base-vm.iso
#   '';
# }

