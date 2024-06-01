-- Diagnostics settings
vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  severity_sort = true,
  float = {
    focusable = false,
  },
  jump = {
    float = true,
  },
})

-- Diagnostic icons
local signs = {
  Error = " ",
  Warn = " ",
  Info = " ",
  Hint = "󰌶 ",
}

for severity, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. severity
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
