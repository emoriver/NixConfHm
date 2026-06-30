{ lib, pkgs, ... }:

{
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = pkgs.stdenv.isx86_64;  # true su x86_64, false su aarch64
    pulse.enable      = true;
    jack.enable       = true;
    wireplumber.enable = true; 
  };
}