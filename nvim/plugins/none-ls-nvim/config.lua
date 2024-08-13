local null_ls = require("null-ls")
local builtins = require("null-ls").builtins
local formatting = builtins.formatting
local diagnostics = builtins.diagnostics

null_ls.setup({
  sources = {
    -- Formatting
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

-- Disable Vale by default and create user command to toggle it
null_ls.disable({ name = "vale" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "rst" },
  desc = "Defining user commands to toggle none-ls.nvim sources",
  callback = function(args)
    vim.api.nvim_buf_create_user_command(args.buf, "NoneLsToggle", function()
      null_ls.toggle({ name = "vale" })
    end, { desc = "Toggle Vale linter" })
  end,
})
