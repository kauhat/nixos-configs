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
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    # Enable QEMU Guest for Proxmox
    services.qemuGuest.enable = lib.mkDefault true;

    # Use the boot drive for grub
    boot.loader.grub.enable = lib.mkDefault true;
    boot.loader.grub.devices = ["nodev"];

    boot.growPartition = lib.mkDefault true;

    # Allow remote updates with flakes and non-root users
    nix.settings.trusted-users = ["root" "@wheel"];
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Enable mDNS for `hostname.local` addresses
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.publish = {
      enable = true;
      addresses = true;
    };

    # Tailscale configuration
    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = ../secrets/tailscaleAuth.age;
    };

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };
}
