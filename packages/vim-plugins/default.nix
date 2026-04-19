{
  fetchFromGitHub,
  fetchpatch,
  vimUtils,
}:
final: prev: {
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

  # Pin smart-splits.nvim to the version that doesn't run tmux commands on startup
  smart-splits-nvim = prev.smart-splits-nvim.overrideAttrs (prevAttrs: {
    version = "2024-02-18";
    src = prevAttrs.src.override {
      rev = "159c4823e3a11c79bb65fc4b8560320c49f738f4";
      sha256 = "sha256-S5I9nQcNGmjqZFn5jQkoG5Oh/mu8oSJpDZpAG07GytA=";
    };
  });

  otter-nvim = prev.otter-nvim.overrideAttrs {
    patches = ./otter-fix-user-commands.patch;
  };

  # Fixes errors in telescope keymaps picker
  telescope-nvim = prev.telescope-nvim.overrideAttrs {
    patches = ./telescope-keymaps-picker.patch;
  };

  nvim-lspconfig = prev.nvim-lspconfig.overrideAttrs {
    patches = ./lspconfig-nix-store-rust-library.patch;
  };

  codecompanion-nvim = prev.codecompanion-nvim.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "19.11.0";
      src = fetchFromGitHub {
        owner = "olimorris";
        repo = "codecompanion.nvim";
        tag = "v${finalAttrs.version}";
        hash = "sha256-z8zcGgq5CBq5OlUZ+GfcvCgVrrFdGUMpJYR0duMigXA=";
      };

      patches = [
        # Allow to set proxy for adapter via opts
        ./codecompanion-add-support-for-per-adapter-proxy.patch
      ];

      # Collision with blink-cmp
      postPatch = ''
        find doc -mindepth 1 \( -name robots.txt -or -not -name '*.txt' \) -delete
      '';
    }
  );

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
