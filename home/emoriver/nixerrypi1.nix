{ config, lib, pkgs, pkgsUnstable, ... }:

{
  imports = [
    ../../modules/home/apps/zsh.nix
    ../../modules/home/apps/git.nix
  ];

  home.username    = "emoriver";
  home.homeDirectory = "/home/emoriver";
  home.stateVersion  = "25.11";

  # Strumenti utili da terminale sul player
  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    fzf
    mpc     # controllo MPD da riga di comando
    ncmpc   # client MPD interattivo da terminale
  ];

  systemd.user.startServices = "sd-switch";
}