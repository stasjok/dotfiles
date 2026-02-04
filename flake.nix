{
  description = "Home Manager configuration of Stas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # Remove optional dependencies
        nuschtosSearch.follows = "";
      };
    };
    catppuccin = {
      url = "github:catppuccin/nix/c11bfcf5671358a12fa2d906e7c859d0644d9b2d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-palette = {
      url = "github:catppuccin/palette";
      flake = false;
    };

    # Neovim plugins
    smart-splits-nvim = {
      # Pin smart-splits.nvim to the version that doesn't run tmux commands on startup
      url = "github:mrjones2014/smart-splits.nvim?rev=159c4823e3a11c79bb65fc4b8560320c49f738f4";
      flake = false;
    };

    # Other inputs
    tree-sitter-jinja2 = {
      url = "github:theHamsta/tree-sitter-jinja2";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixvim,
      catppuccin,
      ...
    }:
    let
      system = "x86_64-linux";
      homeManagerOverlay = import "${home-manager}/overlay.nix";
      pkgs = import "${nixpkgs}/pkgs/top-level" {
        localSystem = system;
        overlays = [
          homeManagerOverlay
          self.overlays.default
        ];
      };
      inherit (pkgs) lib;

      # Home configuration template
      makeHomeConfiguration =
        {
          username ? "stas",
          homeDirectory ? "/home/${username}",
          stateVersion ? "24.11",
          extraModules ? [ ],
          extraSpecialArgs ? { },
          isGenericLinux ? true,
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = extraSpecialArgs // {
            inherit inputs;
          };
          modules = lib.flatten [
            nixvim.homeModules.nixvim
            catppuccin.homeModules.catppuccin
            ./modules
            ./home.nix
            (lib.optional isGenericLinux ./linux.nix)
            {
              home = {
                inherit username homeDirectory stateVersion;
              };
            }
            extraModules
          ];
        };
      makeOverridableHomeConfiguration = args: lib.makeOverridable makeHomeConfiguration args;
    in
    {
      homeConfigurations = {
        stas = makeOverridableHomeConfiguration {
          username = "stas";
        };
        "stas@server2" = makeOverridableHomeConfiguration {
          username = "stas";
          extraModules = [ ./server2.nix ];
        };
        admAsunkinSS = makeOverridableHomeConfiguration {
          username = "admAsunkinSS";
          extraModules = [ ./work.nix ];
        };
      };

      devShells.${system} = pkgs.callPackages ./shell { inherit (self) homeConfigurations; };

      formatter.${system} = pkgs.treefmt;

      checks.${system}.tests = pkgs.callPackage ./tests {
        homeConfiguration = self.homeConfigurations.stas;
      };

      overlays.default = import ./overlay { inherit inputs; };

      # Provide all upstream packages
      legacyPackages.${system} = pkgs;
    };
}
