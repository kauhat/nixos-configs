{
  pkgs,
  nixpkgs,
  self,
  ...
}: let
  proxmox-lxc-base = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"

      self.nixosModules.base
      self.nixosModules.base-lxc
      self.nixosModules.users
    ];
  };

  proxmox-vm-base = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      "${nixpkgs}/nixos/modules/virtualisation/proxmox-image.nix"

      self.nixosModules.base
      self.nixosModules.base-vm
      self.nixosModules.users
    ];
  };

  proxmox-lxc-base-rootfs = proxmox-lxc-base.config.system.build.tarball;
  proxmox-vm-base-iso = proxmox-vm-base.config.system.build.image;
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
      mkdir -p $out/proxmox-templates
      cp -rL "${proxmox-lxc-base-rootfs}/*" $out/proxmox-templates
      cp -rL "${proxmox-vm-base-iso}/*" $out/proxmox-templates
    '';
  }
