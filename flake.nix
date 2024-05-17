{
  description = "Home Manager configuration of Stas";

  inputs = {
    nixpkgs.url = "nixpkgs";
    home-manager = {
      url = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other inputs
    neovim = {
      url = "github:neovim/neovim?ref=release-0.10";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    homeManagerOverlay = import "${home-manager}/overlay.nix";
    pkgs = import "${nixpkgs}/pkgs/top-level" {
      localSystem = system;
      overlays = [homeManagerOverlay self.overlays.default];
    };
    inherit (pkgs) lib;

    # Home configuration template
    makeHomeConfiguration = {
      username ? "stas",
      homeDirectory ? "/home/${username}",
      stateVersion ? "24.05",
      extraModules ? [],
      extraSpecialArgs ? {},
      isGenericLinux ? true,
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = with lib;
          flatten [
            ./modules
            ./home.nix
            (optional isGenericLinux ./linux.nix)
            {home = {inherit username homeDirectory stateVersion;};}
            extraModules
          ];
      };
    makeOverridableHomeConfiguration = args: lib.makeOverridable makeHomeConfiguration args;
  in {
    homeConfigurations = {
      stas = makeOverridableHomeConfiguration {
        username = "stas";
      };
      "stas@server2" = makeOverridableHomeConfiguration {
        username = "stas";
        extraModules = [./server2.nix];
      };
      admAsunkinSS = makeOverridableHomeConfiguration {
        username = "admAsunkinSS";
        extraModules = [./work.nix];
      };
    };

    devShells.${system} = pkgs.callPackages ./shell {inherit (self) homeConfigurations;};

    checks.${system}.tests = pkgs.callPackage ./tests {homeConfiguration = self.homeConfigurations.stas;};

    overlays.default = import ./overlay {inherit inputs;};

    # Provide all upstream packages
    legacyPackages.${system} = pkgs;
  };
}
