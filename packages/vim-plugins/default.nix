{
  lib,
  callPackage,
  neovimUtils,
  vimUtils,
}: let
  plugins = callPackage ./generated.nix {
    inherit (vimUtils) buildVimPlugin;
    inherit (neovimUtils) buildNeovimPlugin;
  };
  overrides = callPackage ./overrides.nix {};
in
  lib.composeExtensions plugins overrides
