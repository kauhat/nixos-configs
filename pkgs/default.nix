# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...} @ args: {
  # example = pkgs.callPackage ./example { };
  proxmox-templates = pkgs.callPackage ./proxmox-templates.nix args;
  toolbx-image = pkgs.callPackage ./toolbx-image.nix args;
}
