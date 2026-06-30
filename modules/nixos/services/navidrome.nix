{ config, lib, ... }:

with lib;

let
  cfg = config.services.myNavidromeSuite;
in
{
  options.services.myNavidromeSuite = {
    enable = mkEnableOption "Configurazione Navidrome Parametrizzata";

    musicDirectory = mkOption {
      type = types.str;
      description = "Path della cartella musica da indicizzare.";
    };

    port = mkOption {
      type = types.int;
      default = 4533;
      description = "Porta su cui far girare l'interfaccia web di Navidrome.";
    };
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        MusicFolder = cfg.musicDirectory;
        Port = cfg.port;
        Address = "0.0.0.0"; # Ascolta su tutte le interfacce della rete locale
        LogLevel = "info";
        ScanSchedule = "@every 30m"; # Scansiona nuovi album ogni 30 minuti
        SessionTimeout = "24h";
      };
    };

    # Apriamo la porta sul firewall del t630
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
