# A base VM with some networking utilities...
{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {
  imports = [
    # "${toString modulesPath}/virtualisation/proxmox-image.nix"
    # ./base.nix
  ];

  config = {
    # Provide a default hostname
    # networking.hostName = lib.mkDefault "nixos-vm-base";

    # Enable QEMU Guest for Proxmox
    services.qemuGuest.enable = lib.mkDefault true;

    # Use the boot drive for grub
    # boot.loader.grub.enable = lib.mkDefault true;
    # boot.loader.grub.devices = ["nodev"];

    # boot.growPartition = lib.mkDefault true;

    # # Default filesystem
    # fileSystems."/" = lib.mkDefault {
    #   device = "/dev/disk/by-label/nixos";
    #   autoResize = true;
    #   fsType = "ext4";
    # };

    # system.build.tarball = {
    #   format = "xz";
    #   compressionCommand = "${pkgs.xz}/bin/xz -T 0 -c";
    # };
  };
}
