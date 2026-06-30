{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.enableDocker {
    virtualisation.docker = {
      enable = true;
      package = pkgs.docker_29;
    };
  };

  options.enableDocker = lib.mkEnableOption "Enable Docker";
}