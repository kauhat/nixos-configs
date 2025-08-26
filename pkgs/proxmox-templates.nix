# Build some template LXC and VM images with my base NixOS install.
# The output files of this package are intended to be uploaded to my
# proxmox cluster.
#
# e.g. at:
# /tank/templates/template/cache/
# /tank/isos/template/iso/
#
{
  pkgs,
  nixos-generators,
  ...
}: let
  proxomx-lxc-base = nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    format = "proxmox-lxc";

    modules = [
      # ../hosts/base.nix
      ../hosts/template-lxc.nix
    ];
  };

  proxomx-vm-base = nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    format = "proxmox";

    modules = [
      # ../hosts/base.nix
      ../hosts/template-vm.nix
    ];
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "proxmox-configurations";
    version = "1.0";
    description = "Proxmox LXC and VM configurations";

    src = null;
    dontUnpack = true;
    dontStrip = true;

    buildInputs = [
      proxomx-lxc-base
      proxomx-vm-base
    ];

    installPhase = ''
      mkdir -p $out/lxc
      find ${proxomx-lxc-base}/tarball -name "*.tar.xz" -print0 | while IFS= read -r -d $'\0' file; do
        ln -s "$file" "$out/lxc/base-$(basename "$file")";
      done

      mkdir -p $out/vm
      find ${proxomx-vm-base} -name "*.vma.zst" -print0 | while IFS= read -r -d $'\0' file; do
        ln -s "$file" "$out/vm/base-$(basename "$file")";
      done
    '';
  }
