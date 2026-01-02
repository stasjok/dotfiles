{
  inputs,
  fetchFromGitHub,
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
  fix-auto-scroll-nvim = mkPlugin "fix-auto-scroll.nvim";
  surround-nvim = mkPlugin "surround.nvim";

  smart-splits-nvim = prev.smart-splits-nvim.overrideAttrs {
    src = inputs.smart-splits-nvim;
  };

  # My fork of mini.nvim
  mini-nvim = prev.mini-nvim.overrideAttrs {
    version = "2026-01-02";
    src = fetchFromGitHub {
      owner = "stasjok";
      repo = "mini.nvim";
      rev = "11f9ad7ffd8f6a3b1865163d97420244448d1efa";
      hash = "sha256-CF2yNYvn9UoWo9e56PmKKxlp2iDUw8BcdEVLidDbY7E=";
    };
    patches = fetchpatch {
      # Remove ':Git' doc tag to avoid clashing with vim-fugitive
      url = "https://github.com/stasjok/mini.nvim/commit/808752f590c9e93532521b12b8f3f7f6e3bfb342.diff";
      hash = "sha256-BmSOHALTtLXe1jQ1P/Qslq3STkreLXXL5vQtGcWT4GE=";
    };
  };

  # Fixes errors in telescope keymaps picker
  telescope-nvim = prev.telescope-nvim.overrideAttrs {
    patches = ./telescope-keymaps-picker.patch;
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
