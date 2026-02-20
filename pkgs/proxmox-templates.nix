{
  pkgs,
  nixpkgs,
  self,
  ...
}: let
  proxmox-lxc-base = nixpkgs.lib.nixosSystem {
    # Use nixpkgs.lib
    system = "x86_64-linux";
    # format = "proxmox-lxc";

    modules = [
      self.nixosModules.base
      self.nixosModules.base-lxc
      self.nixosModules.users # Include the users module for the template
    ];
  };

  proxmox-vm-base = nixpkgs.lib.nixosSystem {
    # Use nixpkgs.lib
    system = "x86_64-linux";
    # format = "proxmox";

    modules = [
      self.nixosModules.base
      self.nixosModules.base-vm
      self.nixosModules.users # Include the users module for the template
    ];
  };

  proxmox-lxc-base-rootfs = proxmox-lxc-base.config.system.build.tarball;
  proxmox-vm-base-iso = proxmox-vm-base.config.system.build.iso;
in
  pkgs.stdenv.mkDerivation {
    pname = "proxmox-configurations";
    version = "1.0";
    description = "Proxmox LXC and VM configurations";
    src = null;
    dontUnpack = true;
    dontStrip = true;
    nativeBuildInputs = [pkgs.coreutils];

    buildInputs = [
      proxmox-lxc-base-rootfs
      proxmox-vm-base-iso
    ];

    installPhase = ''
      mkdir -p $out/lxc
      cp -rL ${proxmox-lxc-base-rootfs} $out/lxc/base-lxc-rootfs.tar.zst
      mkdir -p $out/vm
      cp -rL ${proxmox-vm-base-iso} $out/vm/base-vm.iso
    '';
  }
