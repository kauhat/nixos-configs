# This is your home-manager configuration file.
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  config = {
    # programs.zsh.enable = true;

    # Add an admin user
    users.users.jack = {
      isNormalUser = true;
      description = "It's me, Jack!";
      extraGroups = ["networkmanager" "wheel"];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO4HOkIIuHnAhukRppCJ4lWpR/XfT77cO4b9fFVz2cu jack@jackspc-bazzite"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICukXQCZucPptRM5ciQCEY5/6qvMedGymAtI5yOVCl3F jack@mobile"
      ];
    };
  };
}
