{ inputs, ... }:

{
  imports = [ inputs.kineticwe.homeModules.default ];
  programs.kineticwe.enable = true;

}
