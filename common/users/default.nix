{ config, pkgs, ... }:

{
  users.users.jack = {
    isNormalUser = true;
    description = "It's me, Jack!";
    extraGroups =
      [ "wheel" "docker" "audio" "plugdev" "libvirtd" "adbusers" "dialout" "within" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
    ];
  };
}
