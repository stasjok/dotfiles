{
  description = "Home Manager configuration of Stas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # Remove optional dependencies
        nuschtosSearch.follows = "";
      };
    };
    # Pin to v1.2.1. Before https://github.com/catppuccin/nix/commit/115c3de5635c257bd2a723e06f8262a5edd66d9c
    catppuccin.url = "github:catppuccin/nix/1e4c3803b8da874ff75224ec8512cb173036bbd8";

    # Neovim package
    neovim = {
      url = "github:stasjok/neovim?ref=release-0.10-patched";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim plugins
    mini-nvim = {
      url = "github:stasjok/mini.nvim";
      flake = false;
    };
    fix-auto-scroll-nvim = {
      url = "github:BranimirE/fix-auto-scroll.nvim";
      flake = false;
    };
    vim-mediawiki = {
      url = "github:m-pilia/vim-mediawiki";
      flake = false;
    };
    surround-nvim = {
      url = "github:ur4ltz/surround.nvim?rev=549045828bbd9de0746b411a762fa8c382fb10ff";
      flake = false;
    };
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
    yaml-language-server = {
      url = "github:stasjok/yaml-language-server?rev=36084f03f936d3a0b59934f4bf3ef70bc40bbf92";
      flake = false;
    };
    vale-at-red-hat = {
      url = "github:redhat-documentation/vale-at-red-hat";
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
            nixvim.homeManagerModules.nixvim
            catppuccin.homeManagerModules.catppuccin
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
