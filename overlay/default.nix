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
  # LuaJIT and luv versions matching neovim 0.10.0
  luaInterpreters = let
    packageOverrides = finalLua: prevLua: {
      luv = prevLua.luaLib.overrideLuarocks prevLua.luv {
        version = "1.48.0-2";
        knownRockspec = prev.fetchurl {
          url = "mirror://luarocks/luv-1.48.0-2.rockspec";
          sha256 = "sha256-JPnLAlsAOrBcyF21vWAYrS2XWnZNz3waDAqkn6xcoww=";
        };
        src = prev.fetchurl {
          url = "https://github.com/luvit/luv/releases/download/1.48.0-2/luv-1.48.0-2.tar.gz";
          sha256 = "sha256-LDod3+u09lUCk6QO54n3Ei6XZH7t5RUR9XID3kjAO3o=";
        };
      };
      libluv = prevLua.libluv.overrideAttrs {
        inherit (finalLua.luv) version src;
      };
    };
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
      luajit_2_1 = luajit_2_1.override {
        self = luajit_2_1;
        inherit packageOverrides;
      };
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
