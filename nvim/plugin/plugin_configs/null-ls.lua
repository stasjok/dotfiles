local builtins = require("null-ls").builtins
local formatting = builtins.formatting
local diagnostics = builtins.diagnostics

-- Configuration of null-ls
require("null-ls").setup({
  sources = {
    -- Formatting
    formatting.shfmt,
    formatting.stylua,
    formatting.black,
    formatting.fish_indent,
    formatting.mdformat,
    -- Diagnostics
    diagnostics.markdownlint,
  },
})
