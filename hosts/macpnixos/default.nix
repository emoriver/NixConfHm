{
  pkgs,
  ...
}:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    # pacchetti di sistema
    ../../modules/nixos/system/audio
    ../../modules/nixos/de/plasma6.nix
    ../../modules/nixos/de/niri.nix

    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    # servizi
    #../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/vpn.nix
  ];

  # ----- boot e hardware/configurazioni di base -----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Blacklist conflicting open-source drivers
  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "ssb"
    "brcmsmac"
    "brcmfmac"
    "wl"
  ];

  boot.kernelParams = [
    "radeon.si_support=0"
    "amdgpu.si_support=1"
    "radeon.cik_support=0" # Per sicurezza, disabilita anche Sea Islands
    "amdgpu.cik_support=1"
  ];

  boot.kernelModules = [
    "applesmc" # Apple System Management Controller
    "coretemp" # CPU temperature sensors
  ];

  # serve per emulare arm e compilare localmente
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Config for Radeon D dual card
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Essenziale per app a 32 bit e Wine/Steam
    extraPackages = with pkgs; [
      #vaapiVdpau
      libva-vdpau-driver
      libvdpau-va-gl

      vulkan-loader
      vulkan-validation-layers
    ];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  # Fan module (!!)
  services.mbpfan.enable = true;

  services.upower.enable = true;

  # Regole per Digispark ATtiny85 (Micronucleus)
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="0753", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="0753", MODE:="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  # ----- rete e localizzazione -----
  networking = {
    hostName = "macpnixos";

    networkmanager = {
      enable = true;
      wifi.backend = "iwd"; # Forza NM a usare il motore iwd, perfetto per i chip MediaTek
    };

    wireless.iwd.enable = true; # Rimuoviamo il vecchio wireless.enable e abilitiamo iwd

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ];
    };
  };

  systemd.services.iwd = {
    # Abilita iwd per la gestione della rete WiFi e lo fa partire dopo che la scheda WiFi è stata inizializzata
    after = [ "sys-subsystem-net-devices-wlan0.device" ];
    wants = [ "sys-subsystem-net-devices-wlan0.device" ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "it_IT.UTF-8";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "it_IT.UTF-8/UTF-8"
    ];
  };
  #location.provider = "geoclue2";
  time.timeZone = "Europe/Rome";

  # ----- impostazioni di nix -----
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.overrideAttrs (old: {
        doCheck = false; # Salta i test unitari di Rust che falliscono sul Trashcan
      });
    })
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    warn-dirty = false;

    substituters = [
      "https://cache.nixos.org/"
      "https://niri.cachix.org"
      "https://noctalia.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfry9qGridkHN5sXFcBrpVOaBi8JQ="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ----- servizi di base -----
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      AllowUsers = [ "emoriver" ];
    };
  };

  #services.postgresql = {
  #  enable = true;
  #};

  enableDocker = true;

  # Stampa/Bluetooth (abilita se ti servono su questo host)
  services.printing = {
    enable = true;
    # Se preferisci usare i driver ufficiali Epson invece del driverless:
    drivers = [ pkgs.epson-escpr2 ];
  };

  services.avahi = {
    # Avahi (mDNS) per la scoperta delle stampanti di rete
    enable = true;
    nssmdns4 = true; # Permette di risolvere i nomi .local
    openFirewall = true;
  };

  # ----- programmi e pacchetti di sistema host-level  -----
  programs = {
    zsh.enable = true;
    #git.enable = true;
    ssh.startAgent = true;
  };

  services.gnome.gcr-ssh-agent.enable = false;

  environment.systemPackages = with pkgs; [
    #vim
    curl
    wget
    htop
    btop
    unzip
    zip
    gnupg
    tmux
    parted
    nh

    lm_sensors # For temperature/fan monitoring
    mission-center # Modern system monitor with thermal info
  ];

  environment.etc."ipsec.d/00-global.conf".text = ''
    config setup
      ikev1-policy=accept
  '';

  # ----- btrfs -----
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  system.stateVersion = "25.11";
}
