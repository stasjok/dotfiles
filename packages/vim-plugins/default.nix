{
  lib,
  callPackage,
  neovimUtils,
  vimUtils,
}: let
  plugins = callPackage ./generated.nix {
    inherit (vimUtils) buildVimPluginFrom2Nix;
    inherit (neovimUtils) buildNeovimPluginFrom2Nix;
  };
  overrides = callPackage ./overrides.nix {};
in
  lib.composeExtensions plugins overrides
