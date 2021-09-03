local neogit = {}

function neogit.config()
  require("neogit").setup({
    disable_commit_confirmation = true,
    integrations = {
      diffview = true,
    },
  })
  vim.api.nvim_set_keymap("n", "<leader>g", "<Cmd>Neogit<CR>", { noremap = true })
end

return neogit
