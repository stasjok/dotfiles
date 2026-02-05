{ lib, ... }:
{
  lsp.inlayHints.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<Leader>I";
      action = lib.nixvim.mkRaw ''
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end
      '';
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<Leader>bi";
      action = lib.nixvim.mkRaw ''
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
        end
      '';
    }
  ];
}
