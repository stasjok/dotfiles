{lib}: final: prev: {
  # Ansible 2.12 (last support for python 2.6)
  ansible-core = prev.ansible-core.overridePythonAttrs (prevAttrs: rec {
    version = "2.12.10";
    src = prevAttrs.src.override {
      inherit version;
      hash = "sha256-/rHfYXOM/B9eiTtCouwafeMpd9Z+hnB7Retj0MXDwjY=";
    };
    makeWrapperArgs = [
      "--suffix ANSIBLE_STRATEGY_PLUGINS : ${final.mitogen}/${final.python.sitePackages}/ansible_mitogen"
      "--set-default ANSIBLE_STRATEGY mitogen_linear"
    ];
    propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [final.mitogen];
    # Ansible 2.12 doesn't have 'packaging/cli-doc/build.py' script
    # Reverts https://github.com/NixOS/nixpkgs/commit/e6b3cd9d23fa0078d73f1c5dc3b3e533e832b26c
    postInstall = ''
      installManPage docs/man/man1/*.1
    '';
  });

  # Ansible community version matching core
  ansible = prev.ansible.overridePythonAttrs (prevAttrs: rec {
    version = "5.10.0";
    src = prevAttrs.src.override {
      inherit version;
      hash = "sha256-x39Vanw9mUj4ZjnFdCqohb4lp829o7+0GoMUtgozQeg=";
    };
    propagatedBuildInputs = lib.unique (prevAttrs.propagatedBuildInputs
      ++ (with final; [
        # json_query filter
        jmespath
      ]));
  });
}
