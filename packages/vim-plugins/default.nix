{
  inputs,
  fetchpatch,
  vimUtils,
}: final: prev: let
  # Convert flake input to vim plugin
  mkPlugin' = pname: attrs: let
    src = inputs.${builtins.replaceStrings ["."] ["-"] pname};
  in
    vimUtils.buildVimPlugin ({
        inherit pname src;
        version = src.lastModifiedDate;
      }
      // attrs);
  mkPlugin = name: mkPlugin' name {};
in {
  # Flake input plugins
  mini-nvim = mkPlugin "mini.nvim";
  smart-splits-nvim = mkPlugin "smart-splits.nvim";
  vim-jinja2-syntax = mkPlugin "vim-jinja2-syntax";
  fix-auto-scroll-nvim = mkPlugin "fix-auto-scroll.nvim";
  surround-nvim = mkPlugin "surround.nvim";

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
