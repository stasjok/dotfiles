{lib}: final: prev: {
  # Intergate ansible_mitogen
  ansible-core = prev.ansible-core.overridePythonAttrs (prevAttrs: {
    makeWrapperArgs = [
      "--suffix ANSIBLE_STRATEGY_PLUGINS : ${final.mitogen}/${final.python.sitePackages}/ansible_mitogen"
      "--set-default ANSIBLE_STRATEGY mitogen_linear"
    ];
    propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [final.mitogen];
  });

  ansible = prev.ansible.overridePythonAttrs (prevAttrs: {
    propagatedBuildInputs = lib.unique (prevAttrs.propagatedBuildInputs
      ++ (with final; [
        # json_query filter
        jmespath
      ]));
  });
}
