{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    #questa maledetta piccola riga causa la compilazione del kernel localmente...!!
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
  
    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    #../../modules/nixos/system/persistence/nixerrypi.nix
  ];

  # ── Identità macchina ──────────────────────────────────────────────────────
  networking.hostName = "nixerrypi1";
  time.timeZone       = "Europe/Rome";
  i18n.defaultLocale  = "it_IT.UTF-8";

  # ── Raspberry Pi 4B ───────────────────────────────────────────────────────
  #hardware.enableRedistributableFirmware = true;
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

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
        "aegm3" = {
          psk = "password_1";
          priority = 10;
        };
        "aegm1" = {
          psk = "password_2";
          priority = 5;
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22    # SSH
        53    # DNS UDP
        80
        3000
      ];
      allowedUDPPorts = [ 
        53     # DNS UDP
      ];
    };
  };

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
  ];

  # ── AdGuard Home — DNS Blocker Nativo ──────────────────────────────────────
  services.adguardhome = {
    enable = true;
    openFirewall = false; 
  };

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
  };

  # ── Nix ────────────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org/"
      # Aggiungi altri se li usi (es. Cachix)
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
