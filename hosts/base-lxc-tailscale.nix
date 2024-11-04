# A base VM with some networking utilities...
{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {
  imports = [];

  config = {
    # Tailscale configuration
    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = "/etc/tailscale/auth_key"; # Path to the hardcoded Tailscale key file
      interfaceName = "userspace-networking";
    };

    # Create the Tailscale key file
    environment.etc."tailscale/auth_key".text = "tskey-auth-kbUqToUTGV11CNTRL-FeUjYxdytM79xmBXRCTLV7oP1qjj5cRJ";
    environment.etc."tailscale/auth_key".mode = "0600";
  };
}
