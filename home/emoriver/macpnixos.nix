{
  pkgs,
  pkgsUnstable,
  ...
}:

{
  # Import delle app Home-Manager (moduli)
  imports = [
    ../../modules/home/apps/zsh.nix
    ../../modules/home/apps/git.nix
    ../../modules/home/apps/firefox.nix
    #../../modules/home/apps/vscodium.nix
    #../../modules/home/apps/kiro.nix
    ../../modules/home/apps/ghostty.nix

    ../../modules/home/apps/rclone/rclone.nix
    ../../modules/home/apps/rclone/rclone-sync.nix
    ../../modules/home/apps/rclone/rclone-mount.nix

    #../../modules/home/de/noctalia.nix
    #../../modules/home/de/niri.nix
    #../../modules/home/de/kineticwe.nix
  ];

  # Identità + versione HM
  home.username = "emoriver";
  home.homeDirectory = "/home/emoriver";
  home.stateVersion = "25.11";

  # rclone
  apps.rclone.enable = true;
  apps.rclone.withExampleOneDrive = true; # solo se vuoi un esempio base

  apps.rcloneSync = {
    enable = true;
    remoteName = "onedrive_personale"; # nome del remote configurato
    targetDir = "/home/emoriver/OneDriveSync"; # cartella locale
    frequency = "hourly"; # oppure "daily", "weekly", ecc.
  };

  apps.rcloneMount = {
    enable = true;
    remoteName = "onedrive_personale"; # nome del remote configurato
    mountPoint = "/home/emoriver/OneDrive"; # cartella locale
    extraOptions = [
      "--vfs-cache-mode"
      "writes"
    ]; # opzioni rclone mount
  };

  # Pacchetti utente (se vuoi aggiunte "sciolte")
  home.packages =
    (with pkgs; [
      bat
      eza
      fd
      ripgrep
      fzf
      jq
      yq-go
      spotify
      keepassxc
      #mailspring
      thunderbird
      rawtherapee
      exiftool
      obsidian
      gimp
      arduino-ide
      nicotine-plus
      filezilla
      winbox
      imagemagick
      yazi
      hugin
      nixd
      nixfmt
      angryipscanner
      zed-editor
      thunar
      tumbler
      libgsf
      ffmpegthumbnailer
    ])
    ++ (with pkgsUnstable; [
      #kiro  # installato tramite modules/home/apps/kiro.nix
      rapidraw
    ]);

  # Esempio di file utente gestito da HM
  #home.file.".config/myapp/config.toml".text = ''
  #  # Config specifica per host__1__
  #  enabled = true
  #'';

  /*
    systemd.user.services.tumblerd = {
      Unit = {
        Description = "Tumbler thumbnail service";
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.tumbler}/lib/tumbler-1/tumblerd";
        Restart = "on-failure";
      };
    };
  */

  systemd.user.startServices = "sd-switch";
}
