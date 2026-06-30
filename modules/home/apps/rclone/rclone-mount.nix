{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.apps.rcloneMount;
in
{
  options.apps.rcloneMount = {
    enable = lib.mkEnableOption "Abilita il mount automatico di OneDrive con rclone";
    remoteName = lib.mkOption {
      type = lib.types.str;
      default = "onedrive";
      description = "Nome del remote rclone configurato per OneDrive";
    };
    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/OneDrive";
      description = "Percorso locale dove montare OneDrive";
    };
    extraOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--vfs-cache-mode"
        "writes"
      ];
      description = "Opzioni aggiuntive da passare a rclone mount";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ rclone ];

    systemd.user.services.rclone-mount = {
      Unit = {
        Description = "Mount OneDrive con rclone";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount ${cfg.remoteName}: ${cfg.mountPoint} ${lib.concatStringsSep " " cfg.extraOptions}
        '';
        ExecStop = "${pkgs.util-linux}/bin/fusermount -u ${cfg.mountPoint}";
        Restart = "always";
        Type = "notify";
        TimeoutSec = 60;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Assicura che la directory di mount esista
    home.activation.createMountDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${cfg.mountPoint}
    '';
  };
}
