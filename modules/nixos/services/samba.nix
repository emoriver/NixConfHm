{ config, lib, ... }:

with lib;

let
  cfg = config.services.mySambaSuite;
in
{
  options.services.mySambaSuite = {
    enable = mkEnableOption "Configurazione Samba (smb) Parametrizzata";

    workgroup = mkOption {
      type = types.str;
      default = "WORKGROUP";
      description = "Workgroup.";
    };

    srvString = mkOption {
      type = types.str;
      default = "NixOS Samba Server";
      description = "Nome del server.";
    };

    netbiosName = mkOption {
      type = types.str;
      default = "nixos-samba";
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

      settings = {
        global = {
          "workgroup" = cfg.workgroup;
          "server string" = cfg.srvString;
          "netbios name" = cfg.netbiosName;
          "security" = "user";
          # Subnet corretta per la tua rete 192.168.88.x e fallback su 192.168.0.0/16
          "hosts allow" = "192.168.88. 192.168.0.0/16 127.0.0.1 localhost";
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
      allowedTCPPorts = [
        445
        139
      ];
      allowedUDPPorts = [
        137
        138
      ];
    };
  };
}
