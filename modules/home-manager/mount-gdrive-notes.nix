{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Define the service name and the command to run
  serviceName = "mount-gdrive-notes";
  remoteName = "drive_notes";
  remoteType = "drive";
  scriptPrefix = "gdrive-notes";
in {
  options = {
    # Define a boolean option to enable the service
    services.mountGdriveNotes.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable my Gdrive ~/Notes mount service.";
    };
  };

  config = mkIf config.services.mountGdriveNotes.enable {
    # Scripts to manage remote auth.
    home.packages = [
      (pkgs.writeShellScriptBin "${scriptPrefix}-create-remote" ''
        #!/bin/sh
        rclone config create ${remoteName} ${remoteType}
      '')

      (pkgs.writeShellScriptBin "${scriptPrefix}-reconnect-remote" ''
        #!/bin/sh
        # rclone authorize ${remoteType}
        rclone config reconnect ${remoteName}:
      '')
    ];

    # TODO: Load secrets from Bitwarden CLI?
    systemd.user.services."${serviceName}" = {
      Unit = {
        Description = "Mount Google Drive notes";
        After = ["network-online.target"];
      };

      Service = {
        Type = "notify";
        ExecStartPre = "/usr/bin/env mkdir -p %h/Notes";
        ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/rclone.conf --vfs-cache-mode full --vfs-cache-max-age 96h --vfs-cache-max-size 4G --ignore-checksum mount \"drive_notes:\" \"Notes\"";
        ExecStop = "/bin/fusermount -u %h/Notes/%i";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
