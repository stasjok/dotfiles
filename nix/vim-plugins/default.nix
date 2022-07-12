{ vimUtils, vimPlugins }:

let
  generated = import ./generated.nix { inherit (vimUtils) buildVimPluginFrom2Nix; };
in
generated // {
  lua-dev-nvim = generated.lua-dev-nvim.overrideAttrs (_: {
    patches = [ ./patches/lua-dev-nvim/fix_library.patch ];
  });
}
