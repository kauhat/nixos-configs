{pkgs, ...} @ args: {
  proxmox-templates = pkgs.callPackage ./proxmox-templates.nix args;

  # TODO: Remove?
  # toolbx-image = pkgs.callPackage ./toolbx-image.nix args;

  # TODO: has issues, breaks build.
  # vm-images = pkgs.callPackage ./vm-images.nix args;
}
