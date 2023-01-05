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

    registry = with builtins; {
      nixpkgs.to = (fromJSON (readFile ./flake.lock)).nodes.nixpkgs.locked;
      home-manager.to = (fromJSON (readFile ./flake.lock)).nodes.home-manager.locked;
      dotfiles.to = {
        type = "github";
        owner = "stasjok";
        repo = "dotfiles";
      };
    };
  };

  # Home-manager doesn't install nix package, so do it manually
  home.packages = [
    config.nix.package
  ];
}
