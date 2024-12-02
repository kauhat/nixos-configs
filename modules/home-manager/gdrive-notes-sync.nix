{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Define the service name and the command to run
  serviceName = "gdrive-notes-sync";
  remoteName = "drive_notes";
  remoteType = "drive";
  scriptPrefix = "gdrive-notes";
in {
  options = {
    # Define a boolean option to enable the service
    services.gdriveNotesSync.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable my cloud notes sync service.";
    };

    services.gdriveNotesSync.localPath = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/Notes";
      description = ''
        The path to the directory where notes are stored on your local machine.
      '';
    };
  };

  config = mkIf config.services.gdriveNotesSync.enable {
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

      (pkgs.writeShellScriptBin "${scriptPrefix}-initial-sync" ''
        #!/bin/sh
        ${pkgs.rclone}/bin/rclone \
          --config ~/.config/rclone/rclone.conf \
          bisync "drive_notes:" "${toString config.services.gdriveNotesSync.localPath}" \
          -MvP \
          --create-empty-src-dirs \
          --compare size,modtime,checksum \
          --conflict-resolve newer \
          --conflict-loser delete \
          --conflict-suffix sync-conflict-{DateOnly}- \
          --suffix-keep-extension \
          --resilient \
          --recover \
          --no-slow-hash \
          --drive-skip-gdocs \
          --fix-case \
          --resync \
          # --dry-run \
          # --filters-file ~/.config/systemd/user/rclone.filter.txt \

      '')
    ];

    systemd.user.services."${serviceName}" = {
      Unit = {
        Description = "Sync Google Drive notes";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
        StartLimitIntervalSec = 60;
        StartLimitBurst = 1;
      };

      Service = {
        Type = "oneshot";
        ExecStartPre = "/usr/bin/env mkdir -p ${toString config.services.gdriveNotesSync.localPath}";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone \
            --config=%h/.config/rclone/rclone.conf \
            bisync "drive_notes:" "${toString config.services.gdriveNotesSync.localPath}" \
            -MvP \
            --create-empty-src-dirs \
            --compare size,modtime,checksum \
            --conflict-resolve newer \
            --conflict-loser delete \
            --conflict-suffix sync-conflict-{DateOnly}- \
            --suffix-keep-extension \
            --resilient \
            --recover \
            --no-slow-hash \
            --drive-skip-gdocs \
            --fix-case
        '';
      };
      Install.WantedBy = ["default.target"];
    };

    # Define the systemd user timer
    systemd.user.timers."${serviceName}" = {
      Unit = {
        Description = "Rclone timer (triggers every 10 minutes)";
      };

      Timer = {
        OnCalendar = "*:0/10";
        Persistent = true;
        Unit = "${serviceName}.service";
      };

      Install.WantedBy = ["default.target"];
    };

    # Define the systemd user path watcher
    systemd.user.paths."${serviceName}" = {
      Unit = {
        Description = "Watch for changes in the sync directory";
      };

      Path = {
        PathChanged = "${toString config.services.gdriveNotesSync.localPath}";
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
