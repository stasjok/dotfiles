{
  lib,
  config,
  ...
}:
{
  # Point dotfiles to a work copy of my dotfiles
  nix.registry.dotfiles.to = lib.mkForce {
    type = "git";
    url = "file://${config.home.homeDirectory}/dotfiles";
  };
}
