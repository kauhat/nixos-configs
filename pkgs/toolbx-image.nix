{pkgs, ...}:
# TODO
pkgs.dockerTools.buildImage {
  # The name of the resulting image, used for the Docker tag.
  name = "toolbx-workstation";

  # The tag for the image.
  tag = "latest";

  # The configuration for the container itself, like the entry point.
  # We use systemd to run a full NixOS system in the container.
  config = {
    Cmd = ["${pkgs.systemd}/bin/systemd"];
  };

  # This is the most important part: the NixOS configuration that defines
  # the contents of the image.
  # systemConfig = pkgs.nixos.composeModules {
  #   # Specify the system architecture.
  #   system = "x86_64-linux";

  #   # Import all the NixOS modules needed for the container.
  #   modules = [
  #     # The main configuration for the host.
  #     # You'll need to ensure '../hosts/workstation.nix' exists.
  #     ../hosts/workstation.nix

  #     # This is a crucial module that makes NixOS aware it's running
  #     # inside a container and configures things accordingly.
  #     (import "${pkgs.path}/nixos/modules/virtualisation/oci-containers.nix")
  #   ];
  # };
}
