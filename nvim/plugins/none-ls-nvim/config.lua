local null_ls = require("null-ls")
local builtins = require("null-ls").builtins
local formatting = builtins.formatting
local diagnostics = builtins.diagnostics

null_ls.setup({
  sources = {
    -- Formatting
    formatting.stylua,
    formatting.fish_indent,
    formatting.mdformat,
    formatting.packer,
    -- Diagnostics
    diagnostics.markdownlint,
  },
})
