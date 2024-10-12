{ lib }:
final: prev: {
  # Intergate ansible_mitogen
  ansible-core = prev.ansible-core.overridePythonAttrs (prevAttrs: rec {
    # Latest version supporting python 2.7 and 3.6
    version = "2.16.10";
    src = prevAttrs.src.override {
      inherit version;
      hash = "sha256-qLOHkKZ6+wL0npTx/Nqvz0dMlWeVkjO81xGYasx9SIQ=";
    };

    makeWrapperArgs = [
      "--suffix ANSIBLE_STRATEGY_PLUGINS : ${final.mitogen}/${final.python.sitePackages}/ansible_mitogen"
      "--set-default ANSIBLE_STRATEGY mitogen_linear"
    ];
    propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [ final.mitogen ];
  });

  ansible = prev.ansible.overridePythonAttrs (prevAttrs: rec {
    # Version matching ansible-core
    version = "9.9.0";
    src = prevAttrs.src.override {
      inherit version;
      hash = "sha256-1KhYxV+rD5dG7lWaIwowKz0pZzxOZzRQVW8AupEld84=";
    };

    propagatedBuildInputs = lib.unique (
      prevAttrs.propagatedBuildInputs
      ++ (with final; [
        # json_query filter
        jmespath
      ])
    );
  });
}
