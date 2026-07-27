{ config, myLib, ... }: {
  # Activate yaml parser for ansible
  ftplugin.ansible.content = /* lua */ ''
    vim.treesitter.language.add("ansible", {
      path = "${config.plugins.treesitter.package.builtGrammars.yaml}/parser",
      symbol_name = "yaml"
    })
    -- In case autocmd from treesitter to enable highlight is already executed
    if not vim.b.ts_highlight then
      vim.treesitter.start()
    end
  '';

  # Ftdetect
  filetype = {
    pattern = {
      # Ansible
      ".*ansible[^/]*/.*%.ya?ml" = "ansible";
      ".*/infrastructure/.*%.ya?ml" = "ansible";

      # Ansible hosts
      ".*ansible[^/]*/.*production" = "ansible_hosts";
      ".*ansible[^/]*/.*qa" = "ansible_hosts";
      ".*ansible[^/]*/.*testing" = "ansible_hosts";
    };

    # Avoid matching Taskfile
    filename = {
      "Taskfile.yaml" = "yaml";
      "Taskfile.yml" = "yaml";
    };
  };

  extraFiles = {
    # Indent
    "after/indent/ansible.vim".text = builtins.readFile ./indent.vim;
  }
  // myLib.mkExtraFiles ./. [
    # Tree-sitter queries
    ./queries/ansible/folds.scm
    ./queries/ansible/highlights.scm
    ./queries/ansible/injections.scm
  ];
}
