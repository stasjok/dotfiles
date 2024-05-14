{fetchpatch}: final: prev: {
  # Fix some type annotations
  neodev-nvim = prev.neodev-nvim.overrideAttrs (_: {
    patches = fetchpatch {
      url = "https://github.com/stasjok/neodev.nvim/commit/72a2320e6e6528144b5d8508883102fe40883e22.diff";
      hash = "sha256-D3prfnROYtYNTWJm9/0Tj2FzdRS4TptjD08FuX8jXfg=";
    };
  });

  # Fix symlinked vscode snippets
  luasnip = prev.luasnip.overrideAttrs {
    patches = fetchpatch {
      url = "https://github.com/L3MON4D3/LuaSnip/commit/2b7395217ec97ac020395f5850ba7e18a64d2eba.diff";
      hash = "sha256-WqeoxCJuc50Fl6A19qSErgTz4dnpccPlKOgJndmG5qo=";
    };
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
