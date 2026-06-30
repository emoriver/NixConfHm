{ config, lib, pkgs, ... }:

# ── Impermanence — cosa sopravvive ai riavvii ──────────────────────────────
# Tutto ciò che NON è elencato qui viene cancellato ad ogni riavvio.
# La radice / vive su tmpfs; /persist è su USB.
# ───────────────────────────────────────────────────────────────────────────
{
  environment.persistence."/persist" = {
    # Non mostra i bind mount in `df` e `mount`
    hideMounts = true;

    directories = [
      # ── Sistema ──────────────────────────────────────────────────────────
      "/var/lib/nixos"
      "/etc/nixos"               # configurazione NixOS (questo flake)
      "/etc/ssh"                 # host keys SSH — evita fingerprint che cambia
      "/var/log"                 # log di sistema
      "/var/lib/systemd/coredump"

      # ── Audio ─────────────────────────────────────────────────────────────
      {
        directory = "/var/lib/mpd";
        user      = "mpd";
        group     = "audio";
        mode      = "0755";
      }
      {
        directory = "/var/lib/spotifyd";
        user      = "emoriver";    # deve corrispondere all'utente spotifyd
        group     = "audio";
        mode      = "0700";
      }

      # ── Bluetooth (decommentare se necessario) ────────────────────────────
      # "/var/lib/bluetooth"
    ];

    files = [
      "/etc/machine-id"   # ID stabile per systemd/journald
      "/etc/adjtime"      # calibrazione orologio hardware
    ];
  };

  # ── Guida ai file da creare manualmente in /persist ───────────────────────
  # Dopo il primo avvio con impermanence, crea questi file:
  #
  # 1. Credenziali SMB per il NAS:
  #      sudo nano /persist/smb-credentials
  #    Contenuto:
  #      username=tuoutente
  #      password=tuapassword
  #      domain=WORKGROUP
  #    Poi: sudo chmod 600 /persist/smb-credentials
  #
  # 2. Password Spotify (se non usi OAuth):
  #      sudo nano /persist/spotify-password
  #    Contenuto: solo la password, una riga
  #    Poi: sudo chmod 600 /persist/spotify-password
  #         sudo chown player:audio /persist/spotify-password
  #
  # 3. Chiavi SSH per accesso remoto (opzionale, generate automaticamente
  #    da openssh al primo avvio — ma puoi anche copiare le tue):
  #      sudo ssh-keygen -t ed25519 -f /persist/etc/ssh/ssh_host_ed25519_key -N ""

  # ── Swap su zram (consigliato per evitare scritture sulla SD) ─────────────
  # Usa RAM compressa come swap invece di un file su disco
  zramSwap = {
    enable    = true;
    algorithm = "zstd";
    memoryPercent = 25;   # 25% di 4GB = ~1GB swap compresso
  };
}
