{ buildVimPluginFrom2Nix }:

{
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
    version = "2022-12-08";
    src = builtins.fetchTree {
      type = "github";
      owner = "aserowy";
      repo = "tmux.nvim";
      rev = "3f73843df726e55b92dbb2938edbb3eb6d0746f5";
      narHash = "sha256-ZC3+zr/uoWfCLgFAJ8EMAXdE1yO40PZa77CTUXs502o=";
    };
  };
  vim-fish-syntax = buildVimPluginFrom2Nix {
    pname = "vim-fish-syntax";
    version = "2022-08-05";
    src = builtins.fetchTree {
      type = "github";
      owner = "khaveesh";
      repo = "vim-fish-syntax";
      rev = "f3744201a10addee5f1bf43146b611c39a1a5e4e";
      narHash = "sha256-bXF0IkibtPPSGDvHCDYUrJ2KWCBlnrtuSPfid4cowC0=";
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
}
