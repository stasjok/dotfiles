{fetchpatch}: final: prev: {
  # Fix some type annotations
  neodev-nvim = prev.neodev-nvim.overrideAttrs (_: {
    patches = fetchpatch {
      url = "https://github.com/stasjok/neodev.nvim/commit/72a2320e6e6528144b5d8508883102fe40883e22.diff";
      hash = "sha256-D3prfnROYtYNTWJm9/0Tj2FzdRS4TptjD08FuX8jXfg=";
    };
  });

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
