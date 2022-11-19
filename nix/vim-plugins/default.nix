{ neovimUtils
, vimUtils
, vimPlugins
}:

let
  generated = import ./generated.nix { inherit (vimUtils) buildVimPluginFrom2Nix; };
in
generated // {
  luassert = neovimUtils.buildNeovimPluginFrom2Nix { pname = "luassert"; version = "1.9.0-1"; };

  lua-dev-nvim = generated.lua-dev-nvim.overrideAttrs (_: {
    patches = [ ./patches/lua-dev-nvim/fix_library.patch ];
  });
}
