{pkgs, ...} @ args: {
  proxmox-templates = pkgs.callPackage ./proxmox-templates.nix args;

  # TODO: Remove?
  # toolbx-image = pkgs.callPackage ./toolbx-image.nix args;

  # TODO:
  # vm-images = pkgs.callPackage ./vm-images.nix args;
}
