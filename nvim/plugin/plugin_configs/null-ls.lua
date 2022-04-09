local diagnostics = require("null-ls").builtins.diagnostics
local formatting = require("null-ls").builtins.formatting

-- Configuration of null-ls
require("null-ls").setup({
  sources = {
    diagnostics.shellcheck,
    formatting.shfmt,
    formatting.stylua,
    formatting.black,
  },
})
