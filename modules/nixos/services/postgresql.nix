{ config, pkgs, lib, ... }:

let
  # Script di backup (commentato per ora)
  # backupScript = pkgs.writeShellScript "pg_backup.sh" ''
  #   export PGPASSWORD="EmoPg25."
  #   pg_dump -U emoriver testdb > /var/backups/postgresql/testdb.sql
  # '';
in {
  options.enablePostgresql = lib.mkEnableOption "Enable PostgreSQL service";

  config = lib.mkIf config.enablePostgresql {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      dataDir = "/var/lib/postgresql";

      authentication = ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             0.0.0.0/0               md5
        host    all             all             ::/0                    md5
      '';

      extraConfig = ''
        listen_addresses = '*'
        max_connections = 100
        shared_buffers = 256MB
      '';
    };

    #extraPlugins = [ pkgs.pgvector ];

    /*
    systemd.tmpfiles.rules = [
      "d /var/backups/postgresql 0755 emoriver users -"
    ];

    systemd.services.pgBackup = {
      description = "PostgreSQL Backup Service";
      serviceConfig = {
        ExecStart = "${backupScript}";
        User = "emoriver";
      };
    };

    systemd.timers.pgBackup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  */  
  };
}
