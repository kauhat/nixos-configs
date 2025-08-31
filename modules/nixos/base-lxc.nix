# A base VM with some networking utilities...
{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {
  imports = [
    # "${toString modulesPath}/virtualisation/proxmox-lxc.nix"
    # ./base.nix
  ];

  config = {
    boot.isContainer = true;

    # Supress systemd units that don't work because of LXC
    systemd.suppressedSystemUnits = [
      "dev-mqueue.mount"
      "sys-kernel-debug.mount"
      "sys-fs-fuse-connections.mount"
    ];

    # Provide a default hostname
    # networking.hostName = lib.mkDefault "nixos-lxc-base";

    # system.build.tarball = {
    #   format = "xz";
    #   compressionCommand = "${pkgs.xz}/bin/xz -T 0 -c";
    # };
  };
}
