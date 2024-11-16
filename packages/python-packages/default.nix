{ lib }:
final: prev: {
  # Intergate ansible_mitogen
  ansible-core = prev.ansible-core.overridePythonAttrs (prevAttrs: rec {
    # Latest version supporting python 2.7 and 3.6
    version = "2.16.13";
    src = prevAttrs.src.override {
      inherit version;
      hash = "sha256-RRlOEe/jxMDJuwsRK23cHKUCigG+a0G65ZNXaosRJ68=";
    };

    makeWrapperArgs = [
      "--suffix ANSIBLE_STRATEGY_PLUGINS : ${final.mitogen}/${final.python.sitePackages}/ansible_mitogen"
      "--set-default ANSIBLE_STRATEGY mitogen_linear"
    ];
    propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [ final.mitogen ];
  });

  ansible = prev.ansible.overridePythonAttrs (prevAttrs: rec {
    # Version matching ansible-core
    version = "9.12.0";
    src = prevAttrs.src.override {
      inherit version;
      hash = "sha256-VFVzk/rldo7mQwSRxVt094Mdid0ZjT10Qx7arkQAQpg=";
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
