{inputs}: final: prev: let
  # Add flake inputs to autoArgs
  callPackage = prev.lib.callPackageWith (final // {inherit inputs;});
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
  # LuaJIT version matching neovim 0.10.0
  luaInterpreters = let
    luajit_2_1 = prev.luaInterpreters.luajit_2_1.overrideAttrs {
      version = "2.1.1713484068";
      src = fetchTree {
        type = "github";
        owner = "LuaJIT";
        repo = "LuaJIT";
        rev = "75e92777988017fe47c5eb290998021bbf972d1f";
        narHash = "sha256-UnrsrXqAybmZve/Y86Q34Yn1TupNKm12wkJsfRpHoWw=";
      };
    };
  in
    prev.luaInterpreters
    // {
      luajit_2_1 = luajit_2_1.override {self = luajit_2_1;};
    };

  # Python packages
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [(callPackage ../packages/python {})];

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

  # Freeze packer to the letest version with Mozilla Public License 2.0
  packer = callPackage ../packages/packer {};
}
