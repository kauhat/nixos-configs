{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../common
  ];

  networking.hostName = "vmware-test";
  networking.firewall.enable = false;

  programs.hyprland.enable = true;

  virtualisation.vmware.guest.enable = true;

  hardware.opengl.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  xdg.portal.wlr.enable = true;
  services.dbus.enable = true;

  users.users.jack.initialPassword = "password";
}
