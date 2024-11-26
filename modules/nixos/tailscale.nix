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
    # Tailscale configuration
    services.tailscale = {
      enable = true;
      openFirewall = true;
      # authKeyFile = ../../nixos-configs-private/secrets/tailscaleAuth.age;
    };
  };
}
