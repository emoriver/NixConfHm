{ lib, config, ... }:
/*
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.apps.git;
in
{
  options.apps.git = {
    enable = mkEnableOption "Abilita configurazione Git";
    userName = mkOption {
      type = types.str;
      default = "";
      description = "Git user.name";
    };
    userEmail = mkOption {
      type = types.str;
      default = "";
      description = "Git user.email";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}
*/

{
  programs.git = {
    enable = true;
    settings.user.name = "Andrea Riva";
    settings.user.email = "emoriver@live.it";
  };
}