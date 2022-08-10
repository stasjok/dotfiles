final: prev: {
  vimPlugins = prev.vimPlugins // prev.callPackage ../vim-plugins { inherit (prev) vimPlugins; };
  nodePackages = prev.nodePackages // prev.callPackage ../node-packages/node-composition.nix {
    nodejs = final.nodejs-14_x;
  };

  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-lua = {
        src = fetchTree {
          type = "github";
          owner = "MunifTanjim";
          repo = "tree-sitter-lua";
          rev = "c9ece5b2d348f917052db5a2da9bd4ecff07426c";
          narHash = "sha256-NSsv5sZ8w2wHrtTpvvkoIqOejgfNZGvRac4Znij1UIY=";
        };
      };
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

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-final: python-prev: {
        ansible = python-prev.ansible.overridePythonAttrs (oldAttrs: {
          propagatedBuildInputs = prev.lib.unique (oldAttrs.propagatedBuildInputs ++ (with python-final; [
            # json_query filter
            jmespath
          ]));
        });
        ansible-core = python-prev.ansible-core.overridePythonAttrs (oldAttrs: {
          makeWrapperArgs = [
            "--suffix ANSIBLE_STRATEGY_PLUGINS : ${python-final.mitogen}/${python-final.python.sitePackages}/ansible_mitogen"
            "--set-default ANSIBLE_STRATEGY mitogen_linear"
          ];
          propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ python-final.mitogen ];
        });
      }
    )
  ];
}
