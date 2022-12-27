{
  description = "Home Manager configuration of Stas";

  inputs = {
    nixpkgs.url = "nixpkgs";
    home-manager = {
      url = "home-manager";
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

    # Home configuration template
    makeHomeConfiguration = {
      username ? "stas",
      homeDirectory ? "/home/${username}",
      extraModules ? [],
      extraSpecialArgs ? {},
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules =
          [
            ./home.nix
            {
              home = {
                username = username;
                homeDirectory = homeDirectory;
                stateVersion = "23.05";
              };
            }
          ]
          ++ extraModules;
      };
  in {
    homeConfigurations = {
      stas = makeHomeConfiguration {
        username = "stas";
      };
      admAsunkinSS = makeHomeConfiguration {
        username = "admAsunkinSS";
      };
    };

    overlays.default = import ./nix/overlay;

    # Provide all upstream packages
    legacyPackages.${system} = pkgs;
  };
}
