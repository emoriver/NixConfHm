{ pkgs, ... }:

{

  /*
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
          resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
        }
        {
          timeout = 600;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = {
        lock = "noctalia msg session lock";
      };
    };
  */

  programs.niri = {
    package = pkgs.niri;

    config = ''
      spawn-at-startup "noctalia"
      spawn-at-startup "gnome-keyring-daemon" "--start" "--components=secrets"

      prefer-no-csd

      input {
          keyboard {
              xkb {
                  layout "it"
              }
          }
          touchpad {
              natural-scroll
              tap
          }
      }

      blur {
          passes 2
          offset 3.0
          noise 0.03
          saturation 1.0
      }

      window-rule {
          geometry-corner-radius 8
          clip-to-geometry true
          background-effect {
              blur true
              xray false
          }
      }

      window-rule {
          match app-id="com.mitchellh.ghostty"
          draw-border-with-background false
          opacity 0.9
      }

      layer-rule {
          //match namespace="^noctalia-(background|launcher-overlay|dock)-.*$"
          //geometry-corner-radius 8
          //background-effect {
          //    xray false
          //}
          match namespace="^noctalia-backdrop"
          place-within-backdrop true
      }

      debug {
        // Allows notification actions and window activation from Noctalia.
        honor-xdg-activation-with-invalid-serial
      }

      // -------------------------------------------------

      binds {
          "Mod+T" { spawn "ghostty"; }
          "Mod+D" { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
          "Mod+R" { spawn "thunar"; }
          "Mod+Alt+L" { spawn "noctalia" "msg" "session" "lock"; }
          "Mod+Q" { close-window; }

          "Mod+Left"  { focus-column-left; }
          "Mod+Right" { focus-column-right; }
          "Mod+Up"    { focus-window-up; }
          "Mod+Down"  { focus-window-down; }

          "Mod+Shift+Up"    { focus-workspace-up; }
          "Mod+Shift+Down"  { focus-workspace-down; }
          "Mod+Shift+Left"  { move-column-left; }
          "Mod+Shift+Right" { move-column-right; }

          "Mod+1" { focus-workspace 1; }
          "Mod+2" { focus-workspace 2; }
          "Mod+3" { focus-workspace 3; }

          "Mod+F"       { maximize-column; }
          "Mod+Shift+F" { fullscreen-window; }
          "Mod+Comma"   { consume-window-into-column; }
          "Mod+Period"  { expel-window-from-column; }

          "Mod+S"       { screenshot; }
          "Mod+Shift+S" { screenshot-screen; }
          "Mod+Alt+S"   { screenshot-window; }

          // volume
          "XF86AudioRaiseVolume" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
          "XF86AudioLowerVolume" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
          "XF86AudioMute"        { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SINK@" "toggle"; }

          // luminosità
          "XF86MonBrightnessUp"   { spawn "brightnessctl" "set" "5%+"; }
          "XF86MonBrightnessDown" { spawn "brightnessctl" "set" "5%-"; }
      }
    '';
  };
}
