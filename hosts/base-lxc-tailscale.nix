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
    (modulesPath + "/virtualisation/lxc-container.nix")
  ];

  config = {
    # Tailscale configuration
    services.tailscale = {
      enable = true;
      openFirewall = true;
      interfaceName = "userspace-networking";
      # authKeyFile = ../../nixos-configs-private/secrets/tailscaleAuth.age;
    };
  };
}
