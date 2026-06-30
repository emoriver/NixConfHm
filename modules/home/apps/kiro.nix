{ pkgs, pkgsUnstable, lib, ... }:

{
  home.packages = with pkgs; [
    nil              # language server richiesto da Nix IDE
    nixfmt           # formatter (rinominato da nixfmt-rfc-style in 26.05)
  ];

  programs.kiro = {
    enable = true;
    package = pkgsUnstable.kiro;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
  };

  # Kiro usa ~/.config/Kiro invece di ~/.config/Code,
  # quindi le settings vanno scritte direttamente lì
  home.file.".config/Kiro/User/settings.json" = {
    force = true;
    text = builtins.toJSON {
      "kiroAgent.configureMCP" = "Disabled";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [ "nixfmt" ];
          };
        };
      };
    };
  };
}
