# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, nixos-generators}: {
  # example = pkgs.callPackage ./example { };
  proxmox-nixos-examples = pkgs.callPackage ./proxmox-nixos-examples.nix { inherit nixos-generators; };
}
