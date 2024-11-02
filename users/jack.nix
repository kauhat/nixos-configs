# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  config = {
    # Add an admin user
    users.users.jack = {
      isNormalUser = true;
      description = "Jack Fletcher";
      extraGroups = ["networkmanager" "wheel"];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO4HOkIIuHnAhukRppCJ4lWpR/XfT77cO4b9fFVz2cu"
      ];
    };
  };
}
