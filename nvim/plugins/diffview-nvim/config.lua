local diffview = require("diffview")
local map = vim.keymap.set

diffview.setup({
  enhanced_diff_hl = true,
  key_bindings = {
    view = {
      q = diffview.close,
    },
    file_panel = {
      q = diffview.close,
    },
    file_history_panel = {
      q = diffview.close,
    },
  },
})

map("n", "<Leader>G", "<Cmd>DiffviewOpen<CR>")
map("n", "<Leader>l", "<Cmd>DiffviewFileHistory<CR>")
map("n", "<Leader>L", "<Cmd>DiffviewFileHistory %<CR>")
