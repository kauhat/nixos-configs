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
      authKeyFile = "/etc/tailscale/auth_key"; # Path to the hardcoded Tailscale key file
    };

    # Create the Tailscale key file
    environment.etc."tailscale/auth_key".text = "tskey-auth-kbUqToUTGV11CNTRL-FeUjYxdytM79xmBXRCTLV7oP1qjj5cRJ";
    environment.etc."tailscale/auth_key".mode = "0600";

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };
}
