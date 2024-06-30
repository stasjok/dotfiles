{
  fetchpatch,
  fetchFromGitHub,
}: final: prev: {
  # Fix some type annotations
  neodev-nvim = prev.neodev-nvim.overrideAttrs (_: {
    patches = fetchpatch {
      url = "https://github.com/stasjok/neodev.nvim/commit/72a2320e6e6528144b5d8508883102fe40883e22.diff";
      hash = "sha256-D3prfnROYtYNTWJm9/0Tj2FzdRS4TptjD08FuX8jXfg=";
    };
  });

  # Pin smart-splits.nvim to the version that doesn't run tmux commands on startup
  smart-splits-nvim = prev.smart-splits-nvim.overrideAttrs {
    src = fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "159c4823e3a11c79bb65fc4b8560320c49f738f4";
      hash = "sha256-S5I9nQcNGmjqZFn5jQkoG5Oh/mu8oSJpDZpAG07GytA=";
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
