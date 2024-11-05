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
    networking.hostName = "lxc-http";

    networking.firewall.allowedTCPPorts = [80 443];

    # HTTP reverse proxy
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      # recommendedTlsSettings = true;

      # Configure Nginx as a reverse proxy
      virtualHosts."localhost" = {
        locations."/" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
        };

        locations."/apache/" = {
          proxyPass = "http://localhost:8080/"; # The service you want to proxy
          # extraConfig = ''
          #   proxy_set_header Host $host;
          #   proxy_set_header X-Real-IP $remote_addr;
          #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #   proxy_set_header X-Forwarded-Proto $scheme;
          # '';
        };
      };
    };

    # Enable httpd (Apache HTTP Server)
    services.httpd = {
      enable = true;

      virtualHosts."localhost" = {
        listen = [{port = 8080;}];
        documentRoot = "/";
      };
    };
  };
}
