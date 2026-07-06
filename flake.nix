{
  description = "NixOS + Home Manager multi-host multi-user";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    kineticwe = {
      url = "gitlab:theblackdon/kineticwe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      impermanence,
      flake-utils,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;

      mkNodeRedPackages =
        system: # Packages per Node-RED (buildNpmPackage)
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        import ./modules/nixos/services/node-red-packages/default.nix {
          inherit pkgs;
        };

      mkPkgsUnstable =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      hosts = {
        macpnixos = {
          system = "x86_64-linux";
          hostModule = ./hosts/macpnixos;
          users = {
            emoriver = ./home/emoriver/macpnixos.nix;
          };
        };
        nix-immich-70 = {
          system = "x86_64-linux";
          hostModule = ./hosts/nix-immich-70;
          users = {
            emoriver = ./home/emoriver/nix-immich-70.nix;
          };
        };
        nixerrypi1 = {
          system = "aarch64-linux";
          #impermanence = true;
          hostModule = ./hosts/nixerrypi1;
          users = {
            emoriver = ./home/emoriver/nixerrypi1.nix;
          };
        };
        nixerrypi2 = {
          system = "aarch64-linux";
          #impermanence = true;
          hostModule = ./hosts/nixerrypi2;
          users = {
            emoriver = ./home/emoriver/nixerrypi2.nix;
          };
        };
        nixthint630 = {
          system = "x86_64-linux";
          #impermanence = true;
          hostModule = ./hosts/nixthint630;
          users = {
            emoriver = ./home/emoriver/nixthint630.nix;
          };
        };
      };

      mkNixos =
        name: cfg:
        let
          system = cfg.system;
          pkgsUnstable = mkPkgsUnstable system;

          #extraModules  = if name == "nixerrypi2"
          #                then [ impermanence.nixosModules.impermanence ]
          #                else [];
          extraModules = [ ];
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgsUnstable inputs; };
          modules = extraModules ++ [
            cfg.hostModule
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit pkgsUnstable inputs; };
                users = lib.mapAttrs (user: path: import path) cfg.users;
                backupFileExtension = "backup";
              };
            }
          ];
        };
    in
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      nixosConfigurations = lib.mapAttrs mkNixos hosts;

      packages = lib.genAttrs systems (system: {
        nodeRedPackages = mkNodeRedPackages system;
      });
    };
}
