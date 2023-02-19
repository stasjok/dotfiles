# This file has been generated by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, buildNeovimPluginFrom2Nix, fetchFromGitHub, fetchgit }:

final: prev:
{
  mediawiki-vim = buildVimPluginFrom2Nix {
    pname = "mediawiki.vim";
    version = "2015-11-15";
    src = fetchFromGitHub {
      owner = "chikamichi";
      repo = "mediawiki.vim";
      rev = "26e5737264354be41cb11d16d48132779795e168";
      sha256 = "1laiiww2lhn0v1039n0mx97fyyj7wdzwi0ybwl1ysdik03nxl32f";
    };
    meta.homepage = "https://github.com/chikamichi/mediawiki.vim/";
  };

  surround-nvim = buildVimPluginFrom2Nix {
    pname = "surround.nvim";
    version = "2022-02-01";
    src = fetchFromGitHub {
      owner = "ur4ltz";
      repo = "surround.nvim";
      rev = "549045828bbd9de0746b411a762fa8c382fb10ff";
      sha256 = "0dw10lk7vd2axdd8kf532x9q5hrj6b8qcazni456qy2vrbipyx2x";
    };
    meta.homepage = "https://github.com/ur4ltz/surround.nvim/";
  };

  tmux-nvim = buildVimPluginFrom2Nix {
    pname = "tmux.nvim";
    version = "2023-02-03";
    src = fetchFromGitHub {
      owner = "aserowy";
      repo = "tmux.nvim";
      rev = "feafcf8f48c49c720ee64e745648d69d42cb9c5a";
      sha256 = "13kbr3sg4kgs65s8nmbc1z1k7k24kalh1wqy1lhrlmqz1jjn50yw";
    };
    meta.homepage = "https://github.com/aserowy/tmux.nvim/";
  };

  vim-fish-syntax = buildVimPluginFrom2Nix {
    pname = "vim-fish-syntax";
    version = "2023-02-17";
    src = fetchFromGitHub {
      owner = "khaveesh";
      repo = "vim-fish-syntax";
      rev = "e229becbf4bbee21cc78cd2cf24f57112e33c02a";
      sha256 = "01ffw7k288ghyln79g5fbvyd7kaq36ji0cjm6yb6l5njvnq2kr1i";
    };
    meta.homepage = "https://github.com/khaveesh/vim-fish-syntax/";
  };

  vim-jinja2-syntax = buildVimPluginFrom2Nix {
    pname = "vim-jinja2-syntax";
    version = "2021-06-22";
    src = fetchFromGitHub {
      owner = "Glench";
      repo = "Vim-Jinja2-Syntax";
      rev = "2c17843b074b06a835f88587e1023ceff7e2c7d1";
      sha256 = "13mfzsw3kr3r826wkpd3jhh1sy2j10hlj1bv8n8r01hpbngikfg7";
    };
    meta.homepage = "https://github.com/Glench/Vim-Jinja2-Syntax/";
  };


}
