{pkgs, ...}: 

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
    };
    
    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];

    oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "agnoster";
    };
  };
}