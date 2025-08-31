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
    # Enable QEMU Guest Agent for Proxmox/VMware integration
    services.qemuGuest.enable = lib.mkDefault true;

    # Configure the bootloader (GRUB)
    # boot.loader.grub = {
    #   enable = true;
    #   devices = [ "nodev" ]; # Use this for disk images
    # };

    # # Set up the default filesystem for a VM image
    # fileSystems."/" = {
    #   device = lib.mkDefault "/dev/disk/by-label/nixos";
    #   fsType = "ext4";
    # };

    # Automatically grow the root partition to use all available space
    boot.growPartition = lib.mkDefault true;
  };
}
