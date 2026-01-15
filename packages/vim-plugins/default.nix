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
  surround-nvim = mkPlugin "surround.nvim";

  smart-splits-nvim = prev.smart-splits-nvim.overrideAttrs {
    src = inputs.smart-splits-nvim;
  };

  # Fix Auto Scroll Neovim
  fix-auto-scroll-nvim = vimUtils.buildVimPlugin {
    pname = "fix-auto-scroll.nvim";
    version = "2023-11-23";
    src = fetchFromGitHub {
      owner = "BranimirE";
      repo = "fix-auto-scroll.nvim";
      rev = "c211a42f4030c9ed03a1456919917cdf1a193bd9";
      hash = "sha256-nJdkGwP9L/9Q547PuD0ZZmKvEAxr/59wMXlh8UgTomI=";
    };
    meta.homepage = "https://github.com/BranimirE/fix-auto-scroll.nvim";
  };

  # My fork of mini.nvim
  mini-nvim = prev.mini-nvim.overrideAttrs {
    version = "2026-01-10";
    src = fetchFromGitHub {
      owner = "stasjok";
      repo = "mini.nvim";
      rev = "7065cc7b89647988ed9c810157b670127a930768";
      hash = "sha256-9XZZuKNvqDWUjPmWpdDCRhEvB7uL5PkTGaelGPfZlPg=";
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

  nvim-lspconfig = prev.nvim-lspconfig.overrideAttrs {
    patches = ./lspconfig-nix-store-rust-library.patch;
  };

  codecompanion-nvim = prev.codecompanion-nvim.overrideAttrs {
    # Collision with blink-cmp
    postPatch = ''
      find doc -mindepth 1 \( -name robots.txt -or -not -name '*.txt' \) -delete
    '';
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
