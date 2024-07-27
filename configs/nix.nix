{
  config,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nix;

    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
    };

    registry = let
      flakeLock = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes;
    in {
      # My dotfiles
      dotfiles.to = {
        type = "github";
        owner = "stasjok";
        repo = "dotfiles";
      };

      # Pinned inputs
      nixpkgs.to = flakeLock.nixpkgs.locked;
      home-manager.to = flakeLock.home-manager.locked;
      neovim.to = flakeLock.neovim.locked;
    };
  };

  # Home-manager doesn't install nix package, so do it manually
  home.packages = [
    config.nix.package
  ];
}
