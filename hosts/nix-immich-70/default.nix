{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [ 
    (modulesPath + "/virtualisation/proxmox-lxc.nix")

    # pacchetti di sistema
    #../../modules/nixos/system/audio.nix
    #../../modules/nixos/de/plasma6.nix

    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    # servizi
    #../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/docker.nix
    #../../modules/nixos/services/vpn.nix
    ../../modules/nixos/services/samba.nix
  ];
  
  nix.settings = { sandbox = false; };  
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };


  # ----- impostazioni di nix -----
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


  # ----- servizi di base -----
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

  enableDocker = true;


  # ----- programmi e pacchetti di sistema host-level  -----
  programs = {
    zsh.enable = true;
    #git.enable = true;
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    #vim
    git 
    curl 
    wget 
    htop 
    #btop 
    ripgrep 
    fd 
    unzip 
    zip 
    gnupg 
    tmux
    yazi
  ];

  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  systemd.mounts = [{
    where = "/sys/kernel/debug";
    enable = false;
  }];

  system.stateVersion = "25.11";
}
