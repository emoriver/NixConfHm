{ ... }:

# ── Stack audio ────────────────────────────────────────────────────────────
# PipeWire come server audio principale -> da common
# WirePlumber seleziona automaticamente il DragonFly Black USB
# se è l'unico dispositivo audio collegato.
# ───────────────────────────────────────────────────────────────────────────

{
  services.pipewire.extraConfig.pipewire."10-dragonfly" = {
    "context.properties" = {
      #"default.clock.rate"          = 96000;
      "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
      "default.clock.quantum"       = 1024;
      "default.clock.min-quantum"   = 512;
      "default.clock.max-quantum"   = 2048;
    };
  };

  services.pipewire.wireplumber.extraConfig."10-dragonfly-default" = {
    "monitor.alsa.rules" = [{
      matches = [
        { "node.nick" = "~.*DragonFly.*"; }
        { "node.nick" = "~.*Dragonfly.*"; }
      ];
      actions.update-props = {
        "priority.session"  = 1000;
        "node.description"  = "AudioQuest DragonFly Black";
      };
    }];
  };
}