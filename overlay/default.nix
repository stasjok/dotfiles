final: prev: {
  vimPlugins = prev.vimPlugins // prev.callPackage ../packages/vim-plugins {inherit (prev) vimPlugins;};

  marksman = prev.callPackage ../packages/marksman {};

  lua5_1 = prev.lua5_1.override {
    packageOverrides = luaFinal: luaPrev: {
      plenary-nvim = luaPrev.plenary-nvim.overrideAttrs (_: {
        prePatch = ''
          rm -r lua/luassert
        '';
        dependencies = with final.vimPlugins; [luassert];
      });
    };
  };

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
