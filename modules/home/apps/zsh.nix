{pkgs, ...}:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;  # o autosuggestion.enable = true su versioni più recenti
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship.toml);
  };
}
