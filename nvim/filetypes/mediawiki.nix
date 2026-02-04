{ lib, pkgs, ... }:
{
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
      callback = lib.nixvim.mkRaw ''
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
    vim_mediawiki_preloaded_wikilangs = [ "bash" ];
    vim_mediawiki_ignored_wikilangs = lib.nixvim.emptyTable;
  };

  # Required autoload functions
  extraFiles = {
    "autoload/mediawiki.vim".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/m-pilia/vim-mediawiki/39987c3b7b3af25e223454d28dcfa91605eb693a/autoload/mediawiki.vim";
      hash = "sha256-3u5WaI7wy0B7mehNfafgzm2scOmD1dQyC+6DBq2dL0I=";
    };
    "autoload/mediawiki/fenced_languages.vim".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/m-pilia/vim-mediawiki/39987c3b7b3af25e223454d28dcfa91605eb693a/autoload/mediawiki/fenced_languages.vim";
      hash = "sha256-CQ6Z8Lf1pUPyKhVEG+7erLn6u22+aMe0ocNfHnnGnQU=";
    };
  };
}
