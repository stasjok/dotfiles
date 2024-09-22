{
  helpers,
  inputs,
  ...
}: {
  # Filetype detection
  filetype.extension.mediawiki = "mediawiki";

  # Fenced languages detection autocmd
  autoGroups.vim_mediawiki_fenced_langs.clear = true;
  autoCmd = [
    {
      event = "FileType";
      pattern = "mediawiki";
      group = "vim_mediawiki_fenced_langs";
      desc = "Detect fenced languages in mediawiki documents";
      # Defer fenced_languages detection (need to run after syntax)
      callback = helpers.mkRaw ''
        vim.schedule_wrap(function()
          vim.call("mediawiki#fenced_languages#perform_highlighting")
          -- Define end tag syntax matches after fenced languages to fix highlighting
          vim.cmd([[syntax match wikiSourceEndTag /<\/source>/ contains=htmlEndTag]])
          vim.cmd([[syntax match wikiSyntaxHLEndTag /<\/syntaxhighlight>/ contains=htmlEndTag]])
        end)
      '';
    }
  ];

  # Fenced languages settings
  globals = {
    vim_mediawiki_wikilang_map = {
      sls = "salt";
    };
    vim_mediawiki_preloaded_wikilangs = ["bash"];
    vim_mediawiki_ignored_wikilangs = helpers.emptyTable;
  };

  # Required autoload functions
  extraFiles = {
    "autoload/mediawiki.vim".source = "${inputs.vim-mediawiki}/autoload/mediawiki.vim";
    "autoload/mediawiki/fenced_languages.vim".source = "${inputs.vim-mediawiki}/autoload/mediawiki/fenced_languages.vim";
  };
}
