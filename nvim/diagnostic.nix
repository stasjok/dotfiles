{ lib, ... }:
{
  diagnostic.settings = {
    update_in_insert = true;
    severity_sort = true;
    jump.on_jump = lib.nixvim.mkRaw ''
      function(_, bufnr)
        vim.diagnostic.open_float({
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        })
      end
    '';
    float = {
      focusable = false;
      source = "if_many";
    };

    # Diagnostic icons
    signs.text = lib.nixvim.toRawKeys {
      "vim.diagnostic.severity.ERROR" = "";
      "vim.diagnostic.severity.WARN" = "";
      "vim.diagnostic.severity.INFO" = "";
      "vim.diagnostic.severity.HINT" = "󰌶";
    };
  };
}
