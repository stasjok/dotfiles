final: prev:

{
  vimPlugins = prev.vimPlugins // prev.callPackage ../vim-plugins { inherit (prev) vimPlugins; };
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
      let
        ansibleOverrideAttrs = mitogen: oldAttrs: {
          makeWrapperArgs = [
            "--suffix ANSIBLE_STRATEGY_PLUGINS : ${mitogen}/${final.${python}.sitePackages}/ansible_mitogen"
            "--set-default ANSIBLE_STRATEGY mitogen_linear"
          ];
          propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ mitogen ];
        };
      in
      {
        mitogen_0_2 = python-prev.mitogen.overridePythonAttrs (oldAttrs: rec {
          version = "0.2.10";
          src = prev.fetchFromGitHub {
            owner = "mitogen-hq";
            repo = "mitogen";
            rev = "v${version}";
            sha256 = "sha256-SFwMgK1IKLwJS8k8w/N0A/+zMmBj9EN6m/58W/e7F4Q=";
          };
        });
        ansible = python-prev.ansible.overridePythonAttrs (ansibleOverrideAttrs python-final.mitogen_0_2);
        ansible-base = python-prev.ansible-base.overridePythonAttrs (ansibleOverrideAttrs python-final.mitogen);
        ansible-core = python-prev.ansible-core.overridePythonAttrs (ansibleOverrideAttrs python-final.mitogen);
      };
  })
