local formatting = require("null-ls").builtins.formatting

-- Configuration of null-ls
require("null-ls").setup({
  sources = {
    formatting.shfmt,
    formatting.stylua,
    formatting.black,
    formatting.fish_indent,
  },
})
