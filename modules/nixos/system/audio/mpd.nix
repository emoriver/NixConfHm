{ lib, ... }:
{
  services.mympd = {
    enable = true;
    settings = {
      http_port = 80;
      ssl = false;
      mpd_host = "/run/user/1000/mpd/socket";
    };
  };

  systemd.services.mympd = {
    after = [
      "home-manager-emoriver.service"
      "mpd.service"
      "user@1000.service"
    ];
    #wants = [ "home-manager-emoriver.service" ];
    wants = [ "user@1000.service" ];
    environment.MPD_HOST = "/run/user/1000/mpd/socket";
    serviceConfig = {
      User = lib.mkForce "emoriver";
      Group = lib.mkForce "users";
      DynamicUser = lib.mkForce false;
      ProtectHome = lib.mkForce "no";
      BindReadOnlyPaths = [ "/mnt" ];
      StateDirectory = lib.mkForce "";
      RuntimeDirectory = lib.mkForce "";
    };
  };

  system.activationScripts.myMpdState = ''
    if [ -f /var/lib/mympd/state/default/mpd_host ]; then
      current=$(cat /var/lib/mympd/state/default/mpd_host)
      if [ "$current" != "/run/user/1000/mpd/socket" ]; then
        rm -rf /var/lib/mympd/state/
      fi
    fi
  '';

}
