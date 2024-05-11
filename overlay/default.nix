final: prev: {
  # Fish plugins
  fishPlugins = prev.fishPlugins.overrideScope' (prev.callPackage ../packages/fish-plugins {});

  # Tmux plugins
  tmuxPlugins =
    prev.tmuxPlugins
    // (prev.callPackage ../packages/tmux-plugins {inherit (final.tmuxPlugins) mkTmuxPlugin;});

  # Vim plugins
  vimPlugins = prev.vimPlugins.extend (prev.callPackage ../packages/vim-plugins {});

  # Neovim backports and patches
  neovim-patched = prev.callPackage ../packages/neovim {};

  # Python packages
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [(prev.callPackage ../packages/python {})];

  # Node packages
  nodePackages = prev.nodePackages.extend (prev.callPackage ../packages/node-packages {});

  # Tree-sitter grammars
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-jinja2 = {
        src = fetchTree {
          type = "github";
          owner = "theHamsta";
          repo = "tree-sitter-jinja2";
          rev = "3fa73cd4a871bf88e95d61adc8e66e7fb09016a1";
          narHash = "sha256-LhyWfhtS1M+5m3wVnlHkM7e0yAG+Cfb1iBS1QuslG/c=";
        };
      };
    };
  };

  # Allow changing kubernetes schema URL via settings
  yaml-language-server = prev.yaml-language-server.overrideAttrs {
    src = fetchTree {
      type = "github";
      owner = "stasjok";
      repo = "yaml-language-server";
      rev = "36084f03f936d3a0b59934f4bf3ef70bc40bbf92";
      narHash = "sha256-9n6SNxY0RQIW9baBKwpQmjEjM4uKquHNcGTo7Jbo0kM=";
    };
  };

  # Freeze packer to the letest version with Mozilla Public License 2.0
  packer = prev.callPackage ../packages/packer {};
}
