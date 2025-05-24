{
  inputs,
  fetchpatch,
  vimUtils,
}:
final: prev:
let
  # Convert flake input to vim plugin
  mkPlugin' =
    pname: attrs:
    let
      src = inputs.${builtins.replaceStrings [ "." ] [ "-" ] pname};
    in
    vimUtils.buildVimPlugin (
      {
        inherit pname src;
        version = src.lastModifiedDate;
      }
      // attrs
    );
  mkPlugin = name: mkPlugin' name { };
in
{
  # Flake input plugins
  mini-nvim = mkPlugin' "mini.nvim" {
    patches = fetchpatch {
      # Remove ':Git' doc tag to avoid clashing with vim-fugitive
      url = "https://github.com/stasjok/mini.nvim/commit/e19c76e0c4cca9aab9f6b45a32cbccff09974c69.diff";
      hash = "sha256-p94f+DbPgKY3heB+T+oE33HGCdiyTJMKm5n418XKt1A=";
    };
  };
  fix-auto-scroll-nvim = mkPlugin "fix-auto-scroll.nvim";
  surround-nvim = mkPlugin "surround.nvim";

  smart-splits-nvim = prev.smart-splits-nvim.overrideAttrs {
    src = inputs.smart-splits-nvim;
  };

  # Remove tests because there are invalid lua files there
  nvim-treesitter = prev.nvim-treesitter.overrideAttrs (prev: {
    postPatch = prev.postPatch + "rm -r tests";
    # Improve comment queries performance
    patches = fetchpatch {
      url = "https://github.com/stasjok/nvim-treesitter/commit/b115652fd53fc67fed3086804d37f1b92110e312.diff";
      hash = "sha256-WVr1Jk0j/5IlLjAI1373Y+cQnNwgIEyLiOhk2NV4kME=";
    };
  });
}
