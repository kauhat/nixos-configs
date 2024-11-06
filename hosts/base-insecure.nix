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
    ../users/jack.nix
  ];

  config = {
    # Provide a default hostname
    networking.hostName = lib.mkDefault "base-nixos";

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

    # Some sane packages we need on every system
    environment.systemPackages = with pkgs; [
      vim # for emergencies
      git # for pulling nix flakes
      python3 # for ansible
      rsync
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

    # Add insecure password.
    users.users.jack = {
      initialHashedPassword = "$y$j9T$Rsod1dsxNMq1cnS7YpUey/$9h03jP666xGpwGqTzfHV5/SenSory9cbFAbucrP3IlD";
    };

    system.stateVersion = lib.mkDefault "24.05";
  };
}
