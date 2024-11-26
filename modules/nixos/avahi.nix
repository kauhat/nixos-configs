{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {
  imports = [
  ];

  config = {
    # Enable mDNS for `hostname.local` addresses
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.publish = {
      enable = true;
      addresses = true;
    };
  };
}
