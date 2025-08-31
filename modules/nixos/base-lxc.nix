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
    # Specify that this is a container
    boot.isContainer = true;

    # Suppress systemd units that are irrelevant in a container
    systemd.suppressedSystemUnits = [
      "dev-mqueue.mount"
      "sys-kernel-debug.mount"
      "sys-fs-fuse-connections.mount"
      "proc-sys-fs-binfmt_misc.mount"
      "set-kernel-parameters.service"
    ];
  };
}
