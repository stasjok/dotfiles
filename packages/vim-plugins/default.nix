{
  inputs,
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
  mini-nvim = mkPlugin' "mini.nvim" {
    patches = fetchpatch {
      # Remove ':Git' doc tag to avoid clashing with vim-fugitive
      url = "https://github.com/stasjok/mini.nvim/commit/e19c76e0c4cca9aab9f6b45a32cbccff09974c69.diff";
      hash = "sha256-p94f+DbPgKY3heB+T+oE33HGCdiyTJMKm5n418XKt1A=";
    };
  };
  fix-auto-scroll-nvim = mkPlugin "fix-auto-scroll.nvim";
  surround-nvim = mkPlugin "surround.nvim";

  smart-splits-nvim = prev.smart-splits-nvim.overrideAttrs {
    src = inputs.smart-splits-nvim;
  };

  codecompanion-nvim = prev.codecompanion-nvim.overrideAttrs (prevAttrs: {
    version = "2025-10-23";
    src = prevAttrs.src.override {
      rev = "v17.28.0";
      sha256 = "sha256-UB6VT40bmD2iKXenNs8skGfYLlVFlMFOb2IiufTvmZY=";
    };
    nvimSkipModules = prevAttrs.nvimSkipModules ++ [
      "codecompanion.providers.actions.fzf_lua"
      "codecompanion.providers.actions.snacks"
      "codecompanion.providers.completion.blink.setup"
      "codecompanion.providers.completion.cmp.setup"
    ];
  });

  # Fix :LspPyrightSetPythonPath command
  nvim-lspconfig = prev.nvim-lspconfig.overrideAttrs {
    patches = fetchpatch {
      url = "https://github.com/neovim/nvim-lspconfig/commit/f4dee350521da3b95fffdfdb94f7a1b5cdb88d79.diff";
      hash = "sha256-NgIR4zNC5HLeYc2rBCHV9sjKdLorUTL3liCZdG8EXhA=";
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
