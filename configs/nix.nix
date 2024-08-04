{
  config,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nix;

    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      allow-import-from-derivation = false;
    };

    registry = let
      flakeLock = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes;
    in {
      # My dotfiles
      dotfiles = {
        to = {
          type = "github";
          owner = "stasjok";
          repo = "dotfiles";
        };
        exact = false;
      };

      # Pinned inputs
      nixpkgs.to = flakeLock.nixpkgs.locked;
      home-manager.to = flakeLock.home-manager.locked;
      nixvim = {
        to = flakeLock.nixvim.locked;
        exact = false;
      };
      neovim = {
        to = flakeLock.neovim.locked;
        exact = false;
      };
    };
  };

  # Home-manager doesn't install nix package, so do it manually
  home.packages = [
    config.nix.package
  ];
}
