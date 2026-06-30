{ config, lib, pkgs, ... }:

# ── Streaming ──────────────────────────────────────────────────────────────
# spotifyd: appare come dispositivo Spotify Connect nella tua app.
#           Scegli "RPI Player" dall'app e la musica esce dal DragonFly.
#
# Credenziali: salvate in /persist/spotifyd-credentials (vedi sotto)
# ───────────────────────────────────────────────────────────────────────────
{
  services.spotifyd = {
    enable = true;
    settings.global = {
      device_name  = "nixerrypi2";
      backend      = "alsa";
      device       = "hw:v15,0";
      bitrate      = 320;
      initial_volume = 80;
      volume_normalisation  = true;
      normalisation_pregain = -10;
      cache_path   = "/var/lib/spotifyd/cache";
      username     = "emoriver@live.it";
      password_cmd = "cat /var/lib/spotifyd/password";
    };
  };

  # ── SoundCloud ────────────────────────────────────────────────────────────
  # Non esiste un client nativo per SoundCloud su Linux embedded.
  # Il flusso consigliato:
  #
  # 1. Dal tuo PC, ottieni l'URL diretto con yt-dlp:
  #      yt-dlp -g "https://soundcloud.com/artista/traccia"
  #
  # 2. Crea una playlist .m3u in /mnt/musica/playlists/ (o /var/lib/mpd/playlists/)
  #    con l'URL restituito
  #
  # 3. MPD può aprire stream HTTP direttamente — aggiungi in coda:
  #      mpc add "https://...url-diretto..."
  #
  # In alternativa, installa yt-dlp come helper e crea uno script:
  environment.systemPackages = with pkgs; [
    yt-dlp
    (writeShellScriptBin "sc-play" ''
      # Uso: sc-play "https://soundcloud.com/artista/traccia"
      URL=$(${yt-dlp}/bin/yt-dlp -g "$1" 2>/dev/null | head -1)
      if [ -z "$URL" ]; then
        echo "Errore: impossibile ottenere l'URL dello stream" >&2
        exit 1
      fi
      ${mpc}/bin/mpc clear
      ${mpc}/bin/mpc add "$URL"
      ${mpc}/bin/mpc play
    '')
  ];
}
