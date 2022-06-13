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
      rev = "79b2019c68a2ff5ae4d732d50746c901dd45603a";
      narHash = "sha256-ZYrhr5Zoa1239jyM7H2FoyFdcc69gOlc7OZ6pBmTn9Y=";
    };
  });
  lua-dev-nvim = generated.lua-dev-nvim.overrideAttrs (_: {
    patches = [ ./patches/lua-dev-nvim/fix_library.patch ];
  });
}
