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
    ./base-insecure.nix
    (modulesPath + "/virtualisation/lxc-container.nix")
  ];

  config = {
    # Provide a default hostname
    networking.hostName = lib.mkDefault "nixos-lxc-base";
  };
}
