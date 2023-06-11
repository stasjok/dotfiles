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

        # vim.list_contains and vim.tbl_contains
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/4d04feb6629cb049cb2a13ba35f0c8d3c6b67ff4.diff";
          hash = "sha256-nY25tMOm/C4xLt75xUShY5JsMvEfLjB4xA1+9QrJS5w=";
          excludes = ["runtime/doc/news.txt" "runtime/lua/provider/health.lua"];
        })

        # vim.tbl_islist and vim.tbl_isarray
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/7caf0eafd83b5a92f2ff219b3a64ffae4174b9af.diff";
          hash = "sha256-/ByTAbH5jVjNzX+0lIRa6SNkX2xrl1/QOPhmWD2E3ZM=";
          excludes = ["runtime/doc/news.txt"];
        })

        # vim.iter
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/ab1edecfb7c73c82c2d5886cb8e270b44aca7d01.diff";
          hash = "sha256-7ScZDAL2+bk1rTA75VfA5LG7MgdonOhsq1pPg7BaDJQ=";
          excludes = ["runtime/doc/news.txt"];
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/6b96122453fda22dc44a581af1d536988c1adf41.diff";
          hash = "sha256-ZPEEVvKAMMkGXqa/jQQnRNzVL4xTMTm2X54XLfh4tYQ=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/94894068794dbb99804cda689b6c37e70376c8ca.diff";
          hash = "sha256-6P5KM8oCzgFkCxD+JD6fqlFbWz7BV3b/U3yjnrqH4o0=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/f68af3c3bc92c12f7dbbd32f44df8ab57a58ac98.diff";
          hash = "sha256-5QGSSvNkTZuD9tU4TWxsxpj7yH6FGQ5tkJEIied4UjQ=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/1e73891d696a00b046ab19d245001424b174c931.diff";
          hash = "sha256-sw4B6FHREfkkIbW0qIJPtRnjhCI9zL8cIy8Q3ZypGZA=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/147bb87245cdb348e67c659415d0661d48aa5f1e.diff";
          hash = "sha256-gFUNCMx9Z68c5paLsh7wKAqHnb0Q1k2JmPft8zbX43A=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/ef1801cc7c3d8fe9fd8524a3b677095d4437fc66.diff";
          hash = "sha256-OULPSAIO1Z1842F5kBet9lRcClRHOxopIZEkI6drx2g=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/c65e2203f70cd5d66fcb8ffb26f8cef38f50e04f.diff";
          hash = "sha256-/mhelbybPxTo/AQxPAosebTRIoEKz+IJy6roHIMatHk=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/40db569014471deb5bd17860be00d6833387be79.diff";
          hash = "sha256-XmSf9wMzI9Q3Qrnc7V5o9acbML5cttWQd5S6SEfMXWM=";
        })
        (prev.fetchpatch {
          url = "https://github.com/neovim/neovim/commit/302d3cfb96d7f0c856262e1a4252d058e3300c8b.diff";
          hash = "sha256-njzF6zcLQZ85STebKCVkfuGE7LptNLd/Es4ZqgbnMbw=";
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
