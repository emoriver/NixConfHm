{ config, lib, ... }: # <-- Aggiunto lib qui

with lib;

let
  cfg = config.services.mySambaSuite;
in
{
  options.services.mySambaSuite = {
    enable = mkEnableOption "Configurazione Samba (smb) Parametrizzata";

    workgroup = mkOption {
      type = types.str;
      description = "Workgroup.";
    };

    srvString = mkOption {
      type = types.str;
      description = "Nome del server.";
    };

    netbiosName = mkOption {
      type = types.str;
      description = "Nome Netbios.";
    };

    publicPath = mkOption {
      type = types.str;
      default = "";
      description = "Path pubblico.";
    };

    privatePath = mkOption {
      type = types.str;
      default = "";
      description = "Path privato.";
    };
  };

  config = mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;

      # Struttura settings corretta per Yarara / NixOS stabile
      settings = {
        global = {
          "workgroup" = cfg.workgroup;
          "server string" = cfg.srvString;
          "netbios name" = cfg.netbiosName;
          "security" = "user";
          "hosts allow" = "192.168. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
      }
      // optionalAttrs (cfg.publicPath != "") {
        "public" = {
          "path" = cfg.publicPath;
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "emoriver";
          "force group" = "users";
        };
      }
      // optionalAttrs (cfg.privatePath != "") {
        "private" = {
          "path" = cfg.privatePath;
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "emoriver";
          "force group" = "users";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    networking.firewall = {
      enable = true;
      allowPing = true;
    };
  };
}
