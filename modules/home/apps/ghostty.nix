{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    enableZshIntegration = true;

    settings = {
      theme = "Tomorrow Night Eighties";
      #font-family = "JetBrainsMono Nerd Font";
      font-family = "FiraMono Nerd Font";
      font-size = 10;

      background-opacity = 0.80;
      background-blur = true;
      #background-blur-radius = 20;

      window-padding-x = 10;
      window-padding-y = 10;
      window-padding-balance = true;
      window-decoration = false;

      bell-features = "audio";

      command = "${pkgs.zsh}/bin/zsh";
    };
  };
}
