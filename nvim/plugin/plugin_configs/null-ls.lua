local on_attach = require("plugin_configs.lspconfig.utils").on_attach
local formatting = require("null-ls").builtins.formatting

-- Configuration of null-ls
require("null-ls").setup({
  on_attach = on_attach,
  sources = {
    formatting.shfmt,
    formatting.stylua,
    formatting.black,
  },
})
