# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...} @ args: {
  # example = pkgs.callPackage ./example { };
  proxmox-nixos-examples = pkgs.callPackage ./proxmox-nixos-examples.nix args;
}
