do
  local builtins = require("null-ls").builtins
  local formatting = builtins.formatting
  local diagnostics = builtins.diagnostics

  require("null-ls").setup({
    sources = {
      -- Formatting
      formatting.shfmt,
      formatting.stylua,
      formatting.black,
      formatting.fish_indent,
      formatting.mdformat,
      formatting.packer,
      -- Diagnostics
      diagnostics.markdownlint,
      diagnostics.vale,
    },
  })
end
