
{ config, lib, pkgs, ... }:

let
  cfg = config.apps.rcloneSync;
  rcloneBin = "${pkgs.rclone}/bin/rclone";
in {
  options.apps.rcloneSync = {
    enable = lib.mkEnableOption "Abilita la sincronizzazione automatica di OneDrive con rclone";
    remoteName = lib.mkOption {
      type = lib.types.str;
      default = "onedrive";
      description = "Nome del remote rclone configurato per OneDrive";
    };
    targetDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/OneDriveSync";
      description = "Percorso locale dove sincronizzare i file da OneDrive";
    };
    frequency = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "Frequenza della sincronizzazione (es. hourly, daily, OnCalendar)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rclone ];

    # Crea la directory di destinazione se non esiste
    home.activation.createRcloneSyncDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${cfg.targetDir}"
    '';

    # Servizio systemd utente per eseguire rclone sync
    systemd.user.services.rclone-sync = {
      Unit = {
        Description = "Sincronizza OneDrive con rclone";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${rcloneBin} sync ${cfg.remoteName}: ${cfg.targetDir}";
        TimeoutSec = 300;
      };
    };

    # Timer per eseguire la sincronizzazione periodicamente
    systemd.user.timers.rclone-sync = {
      Unit = {
        Description = "Timer per sincronizzazione OneDrive con rclone";
      };
      Timer = {
        OnCalendar = cfg.frequency;
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
