{
  colorschemes.catppuccin = {
    enableCompiled = true;

    settings = {
      flavour = "macchiato";
      integrations = {
        # Disable default
        nvimtree = false;
        dashboard = false;
        ts_rainbow = false;
        indent_blankline = {enabled = false;};
        # Enable optional
        mini = true;
      };

      custom_highlights = {
        TermCursor = {bg = "#179299";};
        # Don't hide tree-sitter comment highlights
        "@lsp.type.comment.lua" = {};
      };
    };
  };
}
