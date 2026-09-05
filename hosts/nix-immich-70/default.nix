{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")

    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    # servizi
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/samba.nix
  ];

  # ----- Abilitazione del tuo Modulo Samba -----
  services.mySambaSuite = {
    enable = true;
    workgroup = "WORKGROUP";
    srvString = "NixOS Immich LXC";
    netbiosName = "nix-immich-70";

    publicPath = "/srv/shares/public";
    privatePath = "/srv/shares/private";
  };

  # ----- Impostazioni LXC Proxmox -----
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };

  # ----- Impostazioni di Nix -----
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    sandbox = false;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org/"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ----- Servizi di base -----
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      UsePAM = true;
      AllowUsers = [ "emoriver" ];
      PermitEmptyPasswords = "no";
    };
  };

  security.pam.services.sshd.allowNullPassword = false;

  # Se nel tuo docker.nix hai definito l'opzione custom enableDocker:
  enableDocker = true;

  # ----- Programmi e pacchetti di sistema -----
  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    htop
    ripgrep
    fd
    unzip
    zip
    gnupg
    tmux
    yazi
  ];

  services.fstrim.enable = false; # Gestito dall'host Proxmox

  systemd.mounts = [
    {
      where = "/sys/kernel/debug";
      enable = false;
    }
  ];

  system.stateVersion = "25.11";
}
