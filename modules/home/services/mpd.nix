{ config, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/musica";
    dataDir = "${config.home.homeDirectory}/.config/mpd";
    network = {
      startWhenNeeded = true;
      listenAddress = "any";
      port = 6600;
    };
    extraConfig = ''
      audio_output {
        type           "alsa"
        name           "DragonFly Black"
        device         "hw:v15,0"
        mixer_type     "software"
        auto_resample  "no"
        auto_format    "no"
        auto_channels  "no"
        close_on_pause "yes"
      }
      replaygain           "auto"
      replaygain_preamp    "0"
      volume_normalization "no"
      zeroconf_enabled     "no"
      auto_update          "yes"
      auto_update_depth    "3"
    '';
  };
}
