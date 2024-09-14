{
  description = "Home Manager configuration of Stas";

  inputs = {
    nixpkgs.url = "nixpkgs/673d99f1406cb09b8eb6feab4743ebdf70046557";
    home-manager = {
      url = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # Remove optional dependencies
        devshell.follows = "";
        flake-compat.follows = "";
        git-hooks.follows = "";
        home-manager.follows = "";
        nix-darwin.follows = "";
        treefmt-nix.follows = "";
        nuschtosSearch.follows = "";
      };
    };
    catppuccin.url = "github:catppuccin/nix";

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
    vim-jinja2-syntax = {
      url = "github:Glench/Vim-Jinja2-Syntax";
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
    # TODO: Remove when catppuccin-nvim is updated to 2024-08-10 in nixpkgs
    catppuccin-nvim = {
      url = "github:catppuccin/nvim";
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

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    catppuccin,
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
      stateVersion ? "24.11",
      extraModules ? [],
      extraSpecialArgs ? {},
      isGenericLinux ? true,
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = extraSpecialArgs // {inherit inputs;};
        modules = lib.flatten [
          nixvim.homeManagerModules.nixvim
          catppuccin.homeManagerModules.catppuccin
          ./modules
          ./home.nix
          (lib.optional isGenericLinux ./linux.nix)
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
