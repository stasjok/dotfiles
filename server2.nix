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

  # An alias to run currently developed version of Nvim
  programs.fish.shellAliases.nvim-dev = "nix run dotfiles#homeConfigurations.${config.home.username}.config.programs.nixvim.build.nvimPackage --";
}
