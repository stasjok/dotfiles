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

  # Update ansible-language-server to fix variable completion issue
  # https://github.com/ansible/ansible-language-server/issues/587
  ansible-language-server = prev.ansible-language-server.overrideAttrs (prevAttrs: rec {
    version = "1.2.0";
    src = prevAttrs.src.override {
      rev = "v${version}";
      hash = "sha256-5QzwDsWjuq/gMWFQEkl4sqvsqfxTOZhaFBMhjiiOZSY=";
    };

    npmDepsHash = "sha256-bzffCAGn0aYVoG8IDaXd5I3x3AnGl5urX7BaBKf0tVI=";
    npmDeps = final.fetchNpmDeps {
      name = "${prevAttrs.pname}-${version}-npm-deps";
      inherit src;
      hash = npmDepsHash;
    };
    passthru = {inherit npmDeps;};
  });
}
