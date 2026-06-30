{ config, lib, pkgs, ... }:

let
  cfg = config.apps.rclone;
in {
  options.apps.rclone = {
    enable = lib.mkEnableOption "Enable rclone and optional OneDrive config";
    withExampleOneDrive = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include example OneDrive config in rclone.conf";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ rclone ];

    /*home.file.".config/rclone/rclone.conf" = lib.mkIf cfg.withExampleOneDrive {
      text = ''
        [onedrive]
        type = onedrive
        token = {"access_token":"<your-token>","expiry":"<expiry-date>"}
        drive_id = <your-drive-id>
        drive_type = personal
      '';
    };*/
  };
}