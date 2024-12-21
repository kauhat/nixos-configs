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
    # Allow remote updates with flakes and non-root users
    nix.settings.trusted-users = ["root" "@wheel"];
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Some sane packages we need on every system
    environment.systemPackages = with pkgs; [
      vim # for emergencies
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

    # Add insecure password.
    users.users.jack = {
      initialHashedPassword = "$y$j9T$Rsod1dsxNMq1cnS7YpUey/$9h03jP666xGpwGqTzfHV5/SenSory9cbFAbucrP3IlD";
    };

    system.stateVersion = lib.mkDefault "24.05";
  };
}
