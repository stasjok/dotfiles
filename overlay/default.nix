final: prev: {
  # Fish plugins
  fishPlugins = prev.fishPlugins.overrideScope' (prev.callPackage ../packages/fish-plugins {});

  # Tmux plugins
  tmuxPlugins =
    prev.tmuxPlugins
    // (prev.callPackage ../packages/tmux-plugins {inherit (final.tmuxPlugins) mkTmuxPlugin;});

  # Vim plugins
  vimPlugins = prev.vimPlugins.extend (prev.callPackage ../packages/vim-plugins {});

  # Neovim patches
  neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (finalAttrs: prevAttrs: {
    patches =
      prevAttrs.patches
      ++ [
        # fix vim.tbl_get type annotations
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/d3b9feccb39124cefbe4b0c492fb0bc3f777d0b4.diff";
          hash = "sha256-nfuRNcmaJn2AKXywZqbE112VbNDTUfHsbgnPwiiDIZ0=";
        })
      ];
  });

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

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (
        python-final: python-prev: {
          ansible = python-prev.ansible.overridePythonAttrs (oldAttrs: {
            propagatedBuildInputs = prev.lib.unique (oldAttrs.propagatedBuildInputs
              ++ (with python-final; [
                # json_query filter
                jmespath
              ]));
          });
          ansible-core = python-prev.ansible-core.overridePythonAttrs (oldAttrs: {
            makeWrapperArgs = [
              "--suffix ANSIBLE_STRATEGY_PLUGINS : ${python-final.mitogen}/${python-final.python.sitePackages}/ansible_mitogen"
              "--set-default ANSIBLE_STRATEGY mitogen_linear"
            ];
            propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [python-final.mitogen];
          });
        }
      )
    ];
}
