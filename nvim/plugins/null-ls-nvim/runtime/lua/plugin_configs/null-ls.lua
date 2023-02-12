local builtins = require("null-ls").builtins
local formatting = builtins.formatting
local diagnostics = builtins.diagnostics

local M = {}

local config = {
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
}

function M.configure()
  require("null-ls").setup(config)
end

return M