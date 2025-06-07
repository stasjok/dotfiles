{ helpers, ... }:
{
  diagnostic.settings = {
    update_in_insert = true;
    severity_sort = true;
    float = {
      focusable = false;
    };
    jump = {
      float = true;
    };

    # Diagnostic icons
    signs.text = helpers.toRawKeys {
      "vim.diagnostic.severity.ERROR" = "";
      "vim.diagnostic.severity.WARN" = "";
      "vim.diagnostic.severity.INFO" = "";
      "vim.diagnostic.severity.HINT" = "󰌶";
    };
  };
}
