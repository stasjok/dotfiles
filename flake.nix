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
    lib = pkgs.lib;

    # Home configuration template
    makeHomeConfiguration = {
      username ? "stas",
      homeDirectory ? "/home/${username}",
      stateVersion ? "23.05",
      extraModules ? [],
      extraSpecialArgs ? {},
      isGenericLinux ? true,
    }: let
      staticConfig =
        {home = {inherit username homeDirectory stateVersion;};}
        // lib.optionalAttrs isGenericLinux {targets.genericLinux.enable = true;};
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules =
          [
            ./home.nix
            staticConfig
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

    overlays.default = import ./overlay;

    # Provide all upstream packages
    legacyPackages.${system} = pkgs;
  };
}
