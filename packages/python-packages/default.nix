{ lib, fetchPypi }:
final: prev: {
  # Integrate ansible_mitogen
  ansible-core = prev.ansible-core.overridePythonAttrs (prevAttrs: rec {
    # Latest version supporting python 2.7 and 3.6
    version = "2.16.19";
    src = fetchPypi {
      pname = "ansible_core";
      inherit version;
      hash = "sha256-USXyZBIDn/uZo6dyNhhTWrgObvOJRKokU5lzUDiPTvQ=";
    };

    makeWrapperArgs = [
      "--suffix ANSIBLE_STRATEGY_PLUGINS : ${final.mitogen}/${final.python.sitePackages}/ansible_mitogen"
      "--set-default ANSIBLE_STRATEGY mitogen_linear"
    ];

    dependencies = lib.unique (
      prevAttrs.dependencies
      ++ (with final; [
        mitogen
        # json_query filter
        jmespath
      ])
    );
  });

  ansible = prev.ansible.overridePythonAttrs (prevAttrs: rec {
    # Version matching ansible-core
    version = "9.13.0";
    src = prevAttrs.src.override {
      inherit version;
      hash = "sha256-s4mpfR6FwrKtas6elPQQER9pzFqjhFyTDIc7NMDd1uI=";
    };
  });
}
