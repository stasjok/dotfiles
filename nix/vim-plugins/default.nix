{ vimUtils, vimPlugins }:

let
  generated = import ./generated.nix { buildVimPlugin = vimUtils.buildVimPlugin; };
in
generated // {
  onedark-nvim = generated.onedark-nvim.overrideAttrs (_: {
    prePatch = "rm Makefile";
  });
  impatient-nvim = vimPlugins.impatient-nvim.overrideAttrs (_: {
    patches = [ ./patches/impatient-nvim/add_luacache_suffix.patch ];
  });
  lua-dev-nvim = generated.lua-dev-nvim.overrideAttrs (_: {
    patches = [ ./patches/lua-dev-nvim/fix_library.patch ];
  });
}