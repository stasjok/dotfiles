final: prev:

{
  vimPlugins = prev.vimPlugins // prev.callPackage ../vim-plugins { inherit (prev) vimPlugins; };
  tree-sitter-grammars = prev.tree-sitter-grammars // {
    tree-sitter-nix = prev.tree-sitter-grammars.tree-sitter-nix.overrideAttrs (_: {
      src = builtins.fetchTree {
        type = "github";
        owner = "cstrahan";
        repo = "tree-sitter-nix";
        rev = "6d6aaa50793b8265b6a8b6628577a0083d3b923d";
        narHash = "sha256-iYdP50IQ0Kg9kv/U5GsHy3wUTn2O34Oq3Vmre3EzczE=";
      };
    });
  };
  nodePackages = prev.nodePackages // prev.callPackage ../node-packages/node-composition.nix {
    nodejs = final.nodejs-14_x;
  };
} // # Override python packages for all interpreters
prev.lib.genAttrs [
  "python27"
  "python37"
  "python38"
  "python39"
  "python310"
  "python311"
]
  (python: prev.${python}.override {
    packageOverrides = python-final: python-prev:
      {
        ansible = python-prev.ansible.overridePythonAttrs (oldAttrs: {
          propagatedBuildInputs = prev.lib.unique (oldAttrs.propagatedBuildInputs ++ (with python-final; [
            # json_query filter
            jmespath
          ]));
        });
        ansible-core = python-prev.ansible-core.overridePythonAttrs (oldAttrs: {
          makeWrapperArgs = [
            "--suffix ANSIBLE_STRATEGY_PLUGINS : ${python-final.mitogen}/${final.${python}.sitePackages}/ansible_mitogen"
            "--set-default ANSIBLE_STRATEGY mitogen_linear"
          ];
          propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ python-final.mitogen ];
        });
      };
  })
