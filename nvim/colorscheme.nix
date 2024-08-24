{
  colorschemes.catppuccin = {
    enableCompiled = true;

    settings = {
      flavour = "macchiato";

      # Integrations
      default_integrations = false;
      integrations = {
        cmp = true;
        diffview = true;
        gitsigns = true;
        markdown = true;
        mini = {
          enabled = true;
          indentscope_color = "text";
        };
        native_lsp = {
          enabled = true;
          virtual_text = {
            errors = ["italic"];
            hints = ["italic"];
            warnings = ["italic"];
            information = ["italic"];
            ok = ["italic"];
          };
          underlines = {
            errors = ["underline"];
            hints = ["underline"];
            warnings = ["underline"];
            information = ["underline"];
            ok = ["underline"];
          };
          inlay_hints = {background = true;};
        };
        semantic_tokens = true;
        telescope = {enabled = true;};
        treesitter = true;
      };

      custom_highlights = {
        # Don't hide tree-sitter comment highlights
        "@lsp.type.comment.lua" = {};
        "@lsp.type.comment.nix" = {};
      };
    };
  };
}
