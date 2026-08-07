{ config, myLib, ... }: {
  ftplugin.salt.opts = {
    shiftwidth = 2;
    commentstring = "# %s";
  };

  # This autocmd should be before treesitter autocmd
  extraConfigLuaPre = ''
    vim.api.nvim_create_autocmd("FileType", {
      -- Activate also in markup languages
      pattern = { "salt", "sls", "mediawiki" },
      callback = function()
        vim.treesitter.language.add("salt", {
          path = "${config.plugins.treesitter.package.builtGrammars.jinja}/parser",
          symbol_name = "jinja",
        })
      end,
      once = true,
    })
  '';

  # Filetype from old salt-vim plugin
  plugins.treesitter.languageRegister.salt = "sls";

  extraFiles = {
    # Indent
    "indent/salt.vim".text = builtins.readFile ./indent.vim;
  }
  // myLib.mkExtraFiles ./. [
    # Tree-sitter queries
    ./queries/salt/folds.scm
    ./queries/salt/highlights.scm
    ./queries/salt/injections.scm
  ];
}
