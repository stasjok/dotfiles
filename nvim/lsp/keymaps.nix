{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  lsp.keymaps = [
    {
      key = "gd";
      action = mkRaw "require('telescope.builtin').lsp_definitions";
    }
    {
      key = "gD";
      lspBufAction = "declaration";
    }
    {
      key = "<Leader>T";
      action = mkRaw "require('telescope.builtin').lsp_type_definitions";
    }
    {
      key = "<Leader>i";
      action = mkRaw "require('telescope.builtin').lsp_implementations";
    }
    {
      key = "gr";
      action = mkRaw "require('telescope.builtin').lsp_references";
    }
    {
      key = "gs";
      action = mkRaw "require('telescope.builtin').lsp_document_symbols";
    }
    {
      key = "gS";
      action = mkRaw "require('telescope.builtin').lsp_workspace_symbols";
    }
    {
      key = "<Leader>r";
      lspBufAction = "rename";
    }
    {
      key = "<Leader>a";
      mode = [
        "n"
        "x"
      ];
      lspBufAction = "code_action";
    }
    {
      key = "<Leader>d";
      action = mkRaw "function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end";
    }
    {
      key = "<Leader>D";
      action = mkRaw "require('telescope.builtin').diagnostics";
    }
  ];
}
