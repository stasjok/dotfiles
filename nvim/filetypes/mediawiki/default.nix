{
  # Filetype detection
  filetype.extension.mediawiki = "mediawiki";

  # Tree-sitter parser
  plugins.treesitter.languageRegister = {
    wikitext = "mediawiki";
  };

  # Tree-sitter queries
  extraFiles."queries/wikitext/highlights.scm".text = builtins.readFile ./queries/highlights.scm;

  # Highlight headings like in markdown
  highlight = {
    "@markup.heading.wikitext".link = "@markup.heading.markdown";
    "@markup.heading.1.wikitext".link = "@markup.heading.1.markdown";
    "@markup.heading.2.wikitext".link = "@markup.heading.2.markdown";
    "@markup.heading.3.wikitext".link = "@markup.heading.3.markdown";
    "@markup.heading.4.wikitext".link = "@markup.heading.4.markdown";
    "@markup.heading.5.wikitext".link = "@markup.heading.5.markdown";
    "@markup.heading.6.wikitext".link = "@markup.heading.6.markdown";
  };
}
