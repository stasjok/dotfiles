{ buildVimPluginFrom2Nix }:

{
  onedark-nvim = buildVimPluginFrom2Nix {
    pname = "onedark.nvim";
    version = "2022-06-04";
    src = builtins.fetchTree {
      type = "github";
      owner = "ful1e5";
      repo = "onedark.nvim";
      rev = "9f9afacaeb8abe01c5fc666139ccf82d3747d68d";
      narHash = "sha256-4ZZtaZ76GbHQCir+JSCIoavIvfq0M6GFxsGhVY0TQLM=";
    };
  };
  surround-nvim = buildVimPluginFrom2Nix {
    pname = "surround.nvim";
    version = "2022-02-01";
    src = builtins.fetchTree {
      type = "github";
      owner = "ur4ltz";
      repo = "surround.nvim";
      rev = "549045828bbd9de0746b411a762fa8c382fb10ff";
      narHash = "sha256-XXR/48pbeGwKifYrhtEyMsOCUxejuIla60q0fSYFgTc=";
    };
  };
  tmux-nvim = buildVimPluginFrom2Nix {
    pname = "tmux.nvim";
    version = "2022-05-26";
    src = builtins.fetchTree {
      type = "github";
      owner = "aserowy";
      repo = "tmux.nvim";
      rev = "6f6f4eb7152e2eed4bfd75fd1c2207bb66a3fb8e";
      narHash = "sha256-RkT12YinjfjtCmZosj/jYEMkDNLek6qeFpyWFigoLtE=";
    };
  };
  vim-fish-syntax = buildVimPluginFrom2Nix {
    pname = "vim-fish-syntax";
    version = "2022-01-06";
    src = builtins.fetchTree {
      type = "github";
      owner = "khaveesh";
      repo = "vim-fish-syntax";
      rev = "bd6b832f33e8e1e52cb66d288d367e64d4a27afa";
      narHash = "sha256-MRVUf0Q+IKajgnor4QSmEGJ4EeWw9Y526S/DfsYsF5w=";
    };
  };
  vim-jinja2-syntax = buildVimPluginFrom2Nix {
    pname = "vim-jinja2-syntax";
    version = "2021-06-22";
    src = builtins.fetchTree {
      type = "github";
      owner = "Glench";
      repo = "Vim-Jinja2-Syntax";
      rev = "2c17843b074b06a835f88587e1023ceff7e2c7d1";
      narHash = "sha256-57kZn10XBpCRRXsFSSEIUngdIJSj3cmNQHnkObj+ro4=";
    };
  };
  mediawiki-vim = buildVimPluginFrom2Nix {
    pname = "mediawiki.vim";
    version = "2015-11-15";
    src = builtins.fetchTree {
      type = "github";
      owner = "chikamichi";
      repo = "mediawiki.vim";
      rev = "26e5737264354be41cb11d16d48132779795e168";
      narHash = "sha256-Tgza7QAzNu0D5cuDyH/jR3rvTuoV2DRA2MBCKjiPUdE=";
    };
  };
  lua-dev-nvim = buildVimPluginFrom2Nix {
    pname = "lua-dev.nvim";
    version = "2022-05-01";
    src = builtins.fetchTree {
      type = "github";
      owner = "max397574";
      repo = "lua-dev.nvim";
      rev = "54149d1a4b70ba3442d1424a2e27fd36afd02779";
      narHash = "sha256-4CI+zahSziaVeZk7Voc7pNmMOUeQ4OFUIqW8hqD9FpQ=";
    };
  };
}
