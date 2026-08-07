{ config, myLib, ... }: {
  # Plugin
  plugins.ansible = {
    enable = true;

    settings = {
      unindent_after_newline = 1;
      extra_keywords_highlight = 1;
      template_syntaxes = {
        "*.sh.j2" = "sh";
      };
    };
  };

  # This autocmd should be before treesitter autocmd
  extraConfigLuaPre = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ansible",
      callback = function()
        vim.treesitter.language.add("ansible", {
          path = "${config.plugins.treesitter.package.builtGrammars.yaml}/parser",
          symbol_name = "yaml",
        })
      end,
      once = true,
    })
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

  highlight = {
    # https://github.com/pearofducks/ansible-vim/blob/6c42a448e30bc48ae98792bce38970148b0e3c9d/lua/ansible/init.lua#L124-L127
    # "@keyword.ansible.control".link = "Conditional";
    "@keyword.ansible.loop".link = "Special";
    "@keyword.ansible.directive".link = "Identifier";
    "@keyword.ansible.debug".link = "Debug";
  };
}
