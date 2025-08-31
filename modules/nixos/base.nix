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
    ../../users/jack.nix
  ];

  config = {
    # Allow remote updates with flakes and non-root users
    nix.settings.trusted-users = ["root" "@wheel"];
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Enable flakes...
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    time.timeZone = lib.mkDefault "UTC";
    i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";

    networking.useDHCP = lib.mkDefault true;
    networking.nameservers = lib.mkDefault [];

    # Some sane packages we need on every system
    environment.systemPackages = with pkgs; [
      vim # for emergencies
      git # for pulling nix flakes
      python3 # for ansible
      htop # for process monitoring
      iotop # for disk I/O monitoring
      bmon # for network monitoring
      iproute2 # includes `ip` command
    ];

    # Don't ask for passwords
    security.sudo.wheelNeedsPassword = false;

    # Enable ssh
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    services.timesyncd.enable = true;
    services.journald.extraConfig = "Storage=persistent";

    programs.ssh.startAgent = true;

    system.stateVersion = lib.mkDefault "24.05";
  };
}
