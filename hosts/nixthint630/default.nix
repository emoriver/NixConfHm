{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    #questa maledetta piccola riga causa la compilazione del kernel localmente...!!
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4

    # audio
    ../../modules/nixos/system/audio
    ../../modules/nixos/system/audio/dragonfly.nix
    ../../modules/nixos/system/audio/mpd.nix

    ../../modules/nixos/services/streaming.nix
    ../../modules/nixos/services/soulseek.nix

    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    ../../modules/nixos/services/samba.nix
    ../../modules/nixos/services/navidrome.nix

    #../../modules/nixos/system/persistence/nixthint630.nix
  ];

  # ── Configurazione Servizio MPD ──────────────────────────
  systemd.services.mympd.serviceConfig.BindReadOnlyPaths = [ "/mnt" ];

  # ── Configurazione Servizio Soulseek ─────────────────────
  services.mySlskdSuite = {
    enable = true;
    musicDirectory = "/mnt/musica";
    downloadDir = "/mnt/downloads";
    incompleteDir = "/mnt/downloads/incomplete";
    mountUnit = "";
  };

  # ── Configurazione Servizio Samba ────────────────────────
  services.mySambaSuite = {
    enable = true;
    workgroup = "WORKGROUP";
    srvString = "nixthint630";
    netbiosName = "nixthint630";
    publicPath = "/mnt";
    privatePath = "";
  };

  # ── Configurazione Servizio Navidrome ────────────────────
  services.myNavidromeSuite = {
    enable = true;
    musicDirectory = "/mnt/musica";
    port = 4533;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Identità macchina ──────────────────────────────────────────────────────
  networking.hostName = "nixthint630";
  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "it_IT.UTF-8";

  # ── Rete ───────────────────────────────────────────────────────────────────
  # Ethernet via DHCP (consigliato per stabilità audio).
  # WiFi configurabile opzionalmente.
  # ───────────────────────────────────────────────────────────────────────────
  networking = {
    # Ethernet — DHCP automatico
    interfaces.eth0.useDHCP = true;

    #── WiFi (opzionale) ────────────────────────────────────────────────────
    wireless = {
      enable = true;
      networks = {
        "aegm1" = {
          psk = "password_1";
          priority = 10;
        };
        "aegm3" = {
          psk = "password_2";
          priority = 5;
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # myMPD web UI
        5030 # Interfaccia Web slskd
        6600 # MPD
        46855 # spotifyd zeroconf
        50300 # Porta P2P Soulseek
      ];
      allowedUDPPorts = [
        5353 # Utile per mDNS/Avahi
        1900 # UPnP/SSDP
        50300 # Soulseek
      ];
      allowedTCPPortRanges = [
        {
          from = 40000;
          to = 65535;
        } # porte dinamiche
      ];
      allowedUDPPortRanges = [
        {
          from = 57621;
          to = 57621;
        }
        {
          from = 49152;
          to = 65535;
        }
      ];
      extraCommands = ''
        iptables -A INPUT -p udp -d 224.0.0.251 -j ACCEPT
        iptables -A INPUT -p tcp --dport 46855 -j ACCEPT
      '';
    };
  };

  # ── Blocco del Risparmio Energetico (Sempre Acceso) ───────────────────────
  services.logind = {
    settings = {
      Login = {
        # Ignora lo stato di inattività del sistema (previene la sospensione)
        IdleAction = "ignore";

        # Impedisce lo standby se premi accidentalmente il tasto power o chiudi lo chassis
        PowerKey = "ignore";
        SuspendKey = "ignore";
        HibernateKey = "ignore";
      };
    };
  };

  systemd.services.wifi-powersave-off = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.iw}/bin/iw dev wlp2s0 set power_save off";
    };
  };

  # Disabilita completamente i target di sospensione di Systemd
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # ── Pacchetti di sistema ───────────────────────────────────────────────────
  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    htop
    #btop
    git
    curl
    wget
    ripgrep
    fd
    unzip
    zip
    gnupg
    tmux
    yazi

    ffmpeg # decoder audio aggiuntivi
    yt-dlp # resolver stream SoundCloud
  ];

  # ── SSH ────────────────────────────────────────────────────────────────────
  services = {
    # SSH: Per l'accesso remoto
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
        AllowUsers = [ "emoriver" ];
      };
    };

    # mDNS — permette di raggiungere il Pi come rpi-player.local
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
  };

  # ── Nix ────────────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org/"
      # Aggiungi altri se li usi (es. Cachix)
    ];
    trusted-users = [
      "root"
      "emoriver"
    ];
    # trusted-public-keys = [ ... ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";
}
