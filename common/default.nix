{ config, lib, pkgs, ... }:

with lib; {
  imports = [
    ./users
  ];

  config = {
    # boot.tmp.cleanOnBoot = true;
    # boot.kernelModules = [ "wireguard" ];

    system.stateVersion = "23.11";

    programs.fish.enable = true;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [ ];

    nix = {
      package = pkgs.nixVersions.stable;

      settings = {
        auto-optimise-store = true;
        sandbox = true;
        trusted-users = [ "root" "jack" ];
      };
    };

    nixpkgs.config = {
      allowUnfree = true;
      #packageOverrides = import ../pkgs;
    };

    services.journald.extraConfig = ''
      SystemMaxUse=100M
      MaxFileSec=7day
    '';
  };
}
