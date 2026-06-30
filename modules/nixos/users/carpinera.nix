{ pkgs, ... }:

{
  users.users.carpinera = {
    isNormalUser = true;
    description = "Carpinera";
    home = "/home/carpinera";
    createHome = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "git"
      "video"
      "sudo"
      "docker" # se in uso
    ];
    shell = pkgs.zsh;

    initialPassword = "carpinera";

    # ssh-keygen -t ed25519 -C "emoriver@__nome host__"
    openssh.authorizedKeys.keys = [
    #  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMW7C8X/k4K9qmbvrOWorpDz0v1lPcvBTA9psCtWIOtQ emoriver@live.it"

      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAR56Aa22c+Q+Uj+7V7skB6ZldUnfvbxy2dqZIAXbH4D emoriver@barronera"
    #  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/23fWiczmReYRwPaKRwv5dhzZhQWqXgl89OOOxW7G8 emoriver@p16s1"
    ];
  };
}