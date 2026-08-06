{
  # Filetype detection
  filetype.extension.mediawiki = "mediawiki";

  # Tree-sitter parser
  plugins.treesitter.languageRegister = {
    wikitext = "mediawiki";
  };

  extraFiles."queries/wikitext/highlights.scm".text = builtins.readFile ./queries/highlights.scm;
}
