# https://www.joshuamlee.com/nixos-proxmox-vm-images/
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
    ./base-lxc-tailscale.nix
  ];

  config = {
    # Provide a default hostname
    networking.hostName = "lxc-minecraft";

    networking.firewall.allowedTCPPorts = [80 443 25565];

    # Create the Cloudflare API key file

    # Update Cloudflare service DNS record.
    services.cloudflare-dyndns = {
      enable = true;
      apiTokenFile = "/etc/secrets/cloudflare_api_key";
      domains = [
        "minecraft.services.kauh.at"
      ];
    };

    # Minecraft containers...
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = {
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
  };
}
