# https://www.joshuamlee.com/nixos-proxmox-vm-images/
{
  config,
  outputs,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: let
  networkName = "minecraft-bridge";
in {
  imports = [
    outputs.nixosModules.base
  ];

  config = {
    networking.firewall.allowedTCPPorts = [80 443 25565];

    # Update Cloudflare service DNS record...
    services.cloudflare-dyndns = {
      enable = true;
      domains = [
        "minecraft.example.com"
      ];

      # apiTokenFile = ../../nixos-configs-private/secrets/cloudflareDdns.age;
    };

    # Minecraft containers...
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = {
      "gate" = {
        image = "ghcr.io/minekube/gate:latest";
        autoStart = true;
        ports = ["25555:25555/tcp"];
        # extraOptions = ["--network=${networkName}"];
        volumes = [
          "/etc/gate/config.yml:/config.yml"
        ];
      };

      "minecraft_vanilla" = {
        image = "itzg/minecraft-server:stable";
        autoStart = true;
        hostname = "minecraft-vanilla";
        ports = ["25545:25565"];
        # extraOptions = ["--network=${networkName}"];
        environment = {
          EULA = "true";
          MEMORY = "2G";
          MOTD = "Vanilla";
        };
      };

      "minecraft_e2e" = {
        image = "itzg/minecraft-server:java8-multiarch";
        autoStart = true;
        ports = ["25565:25565"];
        volumes = [
          "/Minecraft/e2e:/data:Z"
        ];
        environment = {
          EULA = "true";
          MOD_PLATFORM = "AUTO_CURSEFORGE";
          CF_SLUG = "enigmatica2expert";
          CF_FILENAME_MATCHER = "1.90h";
          MEMORY = "8G";
          VERSION = "1.12.2";
        };
      };
    };

    # systemd.services.init-minecraft-network = {
    #   description = "Create a network bridge for minecraft containers.";
    #   after = ["network.target"];
    #   wantedBy = ["multi-user.target"];
    #   serviceConfig.Type = "oneshot";
    #   script = ''
    #     # Put a true at the end to prevent getting non-zero return code, which will
    #     # crash the whole service.
    #     check=$(${pkgs.podman}/bin/podman network ls | grep "${networkName}" || true)
    #     if [ -z "$check" ]; then
    #       ${pkgs.podman}/bin/podman network create ${networkName}
    #     else
    #       echo "${networkName} already exists"
    #      fi
    #   '';
    # };
  };
}
