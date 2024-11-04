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
    networking.hostName = "proxmox-test";

    networking.firewall.allowedTCPPorts = [80 443];

    # HTTP reverse proxy
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      # recommendedTlsSettings = true;

      # Configure Nginx as a reverse proxy
      virtualHosts."localhost" = {
        locations."/" = {
          proxyPass = "http://localhost:8080"; # The service you want to proxy

          # proxySetHeader = {
          #   "Host" = "$host";
          #   "X-Real-IP" = "$remote_addr";
          #   "X-Forwarded-For" = "$proxy_add_x_forwarded_for";
          #   "X-Forwarded-Proto" = "http";
          # };
        };

        locations."/test" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
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

    # Create a simple index.html file
    environment.etc."httpd/conf/httpd.conf".text = ''
      ServerRoot "/var/www"
      Listen 8080
      <Directory "/var/www">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
      </Directory>
      DocumentRoot "/var/www"
      <IfModule mime_module>
        AddType text/html .html
      </IfModule>
    '';
  };
}
