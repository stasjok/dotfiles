{
  description = "Home Manager configuration of Stas";

  inputs = {
    nixpkgs.url = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: let
    system = "x86_64-linux";
    homeManagerOverlay = import "${home-manager}/overlay.nix";
    pkgs = import "${nixpkgs}/pkgs/top-level" {
      localSystem = system;
      overlays = [homeManagerOverlay self.overlays.default];
    };
    lib = pkgs.lib;

    # Home configuration template
    makeHomeConfiguration = {
      username ? "stas",
      homeDirectory ? "/home/${username}",
      stateVersion ? "23.05",
      extraModules ? [],
      extraSpecialArgs ? {},
      isGenericLinux ? true,
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = with lib;
          flatten [
            ./home.nix
            (optional isGenericLinux ./linux.nix)
            {home = {inherit username homeDirectory stateVersion;};}
            extraModules
          ];
      };
  in {
    homeConfigurations = {
      stas = makeHomeConfiguration {
        username = "stas";
      };
      "stas@server2" = makeHomeConfiguration {
        username = "stas";
        extraModules = [./server2.nix];
      };
      admAsunkinSS = makeHomeConfiguration {
        username = "admAsunkinSS";
      };
    };

    overlays.default = import ./overlay;

    # Provide all upstream packages
    legacyPackages.${system} = pkgs;
  };
}
