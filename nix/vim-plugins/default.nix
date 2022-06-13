{ vimUtils, vimPlugins }:

let
  generated = import ./generated.nix { inherit (vimUtils) buildVimPluginFrom2Nix; };
in
generated // {
  impatient-nvim = vimPlugins.impatient-nvim.overrideAttrs (_: {
    patches = [ ./patches/impatient-nvim/add_luacache_suffix.patch ];
  });
  luasnip = vimPlugins.luasnip.overrideAttrs (_: {
    src = fetchTree {
      type = "github";
      owner = "L3MON4D3";
      repo = "LuaSnip";
      rev = "533e9fd880f208abe0a82471ff43e60b7fafdb24";
    };
  });
  lua-dev-nvim = generated.lua-dev-nvim.overrideAttrs (_: {
    patches = [ ./patches/lua-dev-nvim/fix_library.patch ];
  });
}
