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
      rev = "295cc9e422060b3200234b42cbee6dde1dfee765";
      narHash = "sha256-5W9NAiHa4NbcPLeeIjc0iykUL1uPTWa+OohNHWvB+LI=";
    };
  });
  lua-dev-nvim = generated.lua-dev-nvim.overrideAttrs (_: {
    patches = [ ./patches/lua-dev-nvim/fix_library.patch ];
  });
}
