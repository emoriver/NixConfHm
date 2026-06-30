{ config, lib, pkgs, ... }:

{
  # Pacchetti e impostazioni condivise per user1
  home.packages = with pkgs; [
    # CLI comuni
    curl wget unzip zip
    # aggiungi qui le cose che vuoi su OGNI host
  ];

  # Alias e prompt condivisi
  programs.zsh.shellAliases = {
    gs = "git status -sb";
    lg = "git log --oneline --graph --decorate --all";
  };
}