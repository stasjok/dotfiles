{inputs}: final: prev: let
  inherit (prev) lib;
  # Add flake inputs to autoArgs
  callPackage = lib.callPackageWith (final // {inherit inputs;});
in {
  # Fish plugins
  fishPlugins = prev.fishPlugins.overrideScope (callPackage ../packages/fish-plugins {});

  # Tmux plugins
  tmuxPlugins =
    prev.tmuxPlugins
    // (callPackage ../packages/tmux-plugins {inherit (final.tmuxPlugins) mkTmuxPlugin;});

  # Vim plugins
  vimPlugins = prev.vimPlugins.extend (callPackage ../packages/vim-plugins {});
  # Avoid error when pointing to nixpkgs directory without .git
  # Use only with --no-commit arg
  vimPluginsUpdater = prev.vimPluginsUpdater.overrideAttrs {
    postFixup = ''
      sed -i 's/self.nixpkgs_repo = git.Repo/# \0/' $out/lib/pluginupdate.py
    '';
  };

  # Neovim backports and patches
  neovim-patched = callPackage ../packages/neovim {};

  # Python packages
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [(callPackage ../packages/python-packages {})];

  # Lua interpreters and packages
  luaInterpreters = lib.fix (
    lib.extends (callPackage ../packages/lua-interpreters {}) (_: prev.luaInterpreters)
  );

  # Node packages
  nodePackages = prev.nodePackages.extend (callPackage ../packages/node-packages {});

  # Tree-sitter grammars
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-jinja2 = {
        src = inputs.tree-sitter-jinja2;
      };
    };
  };

  # Allow changing kubernetes schema URL via settings
  yaml-language-server = prev.yaml-language-server.overrideAttrs {
    src = inputs.yaml-language-server;
  };

  # Nix language server
  nixd = prev.nixd.overrideAttrs {
    patches = [
      # Don't return invalid ranges when going to package definition
      (prev.fetchpatch {
        url = "https://github.com/nix-community/nixd/commit/6811dcf03ac055752a3f28cbabf90bd0b0cee417.diff";
        stripLen = 1;
        hash = "sha256-DARLPMR+hFlcrJ5nXBDrONhgr+0JTXQQv25atA6C980=";
      })
    ];
  };

  # Freeze packer to the letest version with Mozilla Public License 2.0
  packer = callPackage ../packages/packer {};
}
