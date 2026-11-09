{pkgs, ...} @ args: {
  proxmox-templates = pkgs.callPackage ./proxmox-templates.nix args;


  # Distrobox experiments...
  # distrobox = pkgs.callPackage ./distrobox.nix args;
  # toolbx-image = pkgs.callPackage ./toolbx-image.nix args;

  # TODO: has issues, breaks build.
  # vm-images = pkgs.callPackage ./vm-images.nix args;
}
