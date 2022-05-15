{ vimUtils, vimPlugins }:

let
  generated = import ./generated.nix { inherit (vimUtils) buildVimPluginFrom2Nix; };
in
generated // {
  impatient-nvim = vimPlugins.impatient-nvim.overrideAttrs (_: {
    patches = [ ./patches/impatient-nvim/add_luacache_suffix.patch ];
  });
  lua-dev-nvim = generated.lua-dev-nvim.overrideAttrs (_: {
    patches = [ ./patches/lua-dev-nvim/fix_library.patch ];
  });
}
