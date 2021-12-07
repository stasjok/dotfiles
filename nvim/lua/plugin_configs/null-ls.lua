local diagnostics = require("null-ls").builtins.diagnostics
local formatting = require("null-ls").builtins.formatting

local null_ls = {}

null_ls.sources = {
  diagnostics.shellcheck,
  formatting.shfmt,
  formatting.stylua,
  formatting.black,
}

return null_ls
