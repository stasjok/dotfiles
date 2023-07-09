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

  # Pin ansible-language-server to v1.0.4 because of variable completion issue
  # https://github.com/ansible/ansible-language-server/issues/587
  ansible-language-server = prev.ansible-language-server.overrideAttrs (prevAttrs: rec {
    version = "1.0.4";
    src = prevAttrs.src.override {
      rev = "v${version}";
      hash = "sha256-IBySScjfF2bIbiOv09uLMt9QH07zegm/W1vmGhdWxGY=";
    };
    patches = [
      # Fix ansible lint config parsing
      (final.fetchpatch {
        url = "https://github.com/ansible/ansible-language-server/pull/577/commits/e39e5580e82af40c9f2a279a471d0c29dba1db7a.diff";
        hash = "sha256-FJW4PLsmJImNJSpD0RwqRX+HOI1kfnEQONBrSWh1irg=";
      })
      # Get module route for FQCN with more than 3 elements
      (final.fetchpatch {
        url = "https://github.com/ansible/ansible-language-server/pull/538/commits/687760b31202c5318445e6287382136ada636f69.diff";
        hash = "sha256-dUnY99JMHKPdPNNFdY5bOGGFnOow31NygkAz3T17LUo=";
      })
    ];

    npmDepsHash = "sha256-rJ1O2OsrJhTIfywK9/MRubwwcCmMbu61T4zyayg+mAU=";
    npmDeps = final.fetchNpmDeps {
      name = "${prevAttrs.pname}-${version}-npm-deps";
      inherit src patches;
      hash = npmDepsHash;
    };
    passthru = {inherit npmDeps;};
  });
}
