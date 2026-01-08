{ lib, ... }:
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
        mini.enabled = true;
        telescope.enabled = true;
      };

      custom_highlights = {
        # Don't hide tree-sitter comment highlights
        "@lsp.type.comment.lua" = lib.nixvim.emptyTable;
        "@lsp.type.comment.nix" = lib.nixvim.emptyTable;
      };
    };
  };
}
