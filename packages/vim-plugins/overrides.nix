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
      url = "https://github.com/stasjok/nvim-treesitter/commit/5efc1eb108a30477519afff50042a02137ece77d.diff";
      hash = "sha256-DrPjTq+aTPurn2ohi0EKx2T0cBNfjiYkbHc6HisNDz0=";
    };
  });
}
