{ pkgs, ... }:

{
  services.xserver.enable = true; # Requiered for SDDM and KDE Plasma 6 even if you use Wayland
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Enable if using Wayland

    #package = pkgs.kdePackages.sddm;  # Use KDE 6 version
    theme = "breeze";

    settings = {
      Theme = {
        Current = "breeze";
        Background = "/etc/nixos/wallpapers/dark_mnt.png"; # Put your image path here
      };
    };
  };

  services.desktopManager.plasma6.enable = true;

  # Strumenti KDE + utility Wayland
  environment.systemPackages = with pkgs; [
    # --- KDE Apps / Utils ---
    kdePackages.gwenview
    kdePackages.discover # GUI per flatpak/aggiornamenti (con fwupd backend)
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.kolourpaint
    kdePackages.ksystemlog
    kdePackages.isoimagewriter
    kdePackages.partitionmanager
    kdePackages.sddm-kcm # Configuration module for SDDM
    kdePackages.filelight
    kdePackages.kdenlive

    # --- Altri tool utili ---
    kdiff3
    # Nota: se la tua nixpkgs non ha "hardinfo2", usa "hardinfo"
    hardinfo2
    haruna
    wayland-utils
    wl-clipboard
  ];
}
