# https://www.joshuamlee.com/nixos-proxmox-vm-images/
{ config, pkgs, modulesPath, lib, system, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    # Provide a default hostname
    networking.hostName = lib.mkDefault "base";

    # Enable QEMU Guest for Proxmox
    services.qemuGuest.enable = lib.mkDefault true;

    # Use the boot drive for grub
    boot.loader.grub.enable = lib.mkDefault true;
    boot.loader.grub.devices = [ "nodev" ];

    boot.growPartition = lib.mkDefault true;

    # Allow remote updates with flakes and non-root users
    nix.settings.trusted-users = [ "root" "@wheel" ];
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Enable mDNS for `hostname.local` addresses
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.avahi.publish = {
      enable = true;
      addresses = true;
    };

    # Tailscale configuration
    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = "/etc/tailscale/auth_key";  # Path to the hardcoded Tailscale key file
    };

    # Create the Tailscale key file
    environment.etc."tailscale/auth_key".text = "tskey-auth-kNqGGVnxT921CNTRL-42Ec6y5GhbPkHmPgPoAqiPX2Acq3pNLM";
    environment.etc."tailscale/auth_key".mode = "0600";

    # Some sane packages we need on every system
    environment.systemPackages = with pkgs; [
      vim  # for emergencies
      git # for pulling nix flakes
      python3 # for ansible
    ];

    # Don't ask for passwords
    security.sudo.wheelNeedsPassword = false;

    # Enable ssh
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    programs.ssh.startAgent = true;

    # Add an admin user
    users.users.jack = {
      isNormalUser = true;
      description = "Jack Fletcher";
      extraGroups = [ "networkmanager" "wheel" ];
      initialHashedPassword = "$y$j9T$Rsod1dsxNMq1cnS7YpUey/$9h03jP666xGpwGqTzfHV5/SenSory9cbFAbucrP3IlD";
    };

    users.users.jack.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO4HOkIIuHnAhukRppCJ4lWpR/XfT77cO4b9fFVz2cu"
    ];

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    system.stateVersion = lib.mkDefault "24.05";
  };
}
