local diffview = require("diffview")
local map = vim.keymap.set

diffview.setup({
  enhanced_diff_hl = true,
  key_bindings = {
    view = {
      gq = diffview.close,
      ["c<CR>"] = "<Cmd>tab Git commit<CR>",
      ["cv<CR>"] = "<Cmd>tab Git commit -v<CR>",
      ca = "<Cmd>tab Git commit --amend<CR>",
      cva = "<Cmd>tab Git commit -v --amend<CR>",
      cvc = "<Cmd>tab Git commit -v <CR>",
    },
    file_panel = {
      gq = diffview.close,
      ["c<CR>"] = "<Cmd>tab Git commit<CR>",
      ["cv<CR>"] = "<Cmd>tab Git commit -v<CR>",
      ca = "<Cmd>tab Git commit --amend<CR>",
      cc = "<Cmd>tab Git commit<CR>",
      ce = "<Cmd>tab Git commit --amend --no-edit<CR>",
      cva = "<Cmd>tab Git commit -v --amend<CR>",
      cvc = "<Cmd>tab Git commit -v <CR>",
    },
    file_history_panel = {
      gq = diffview.close,
    },
  },
})

map("n", "<Leader>G", "<Cmd>DiffviewOpen<CR>")
map("n", "<Leader>l", "<Cmd>DiffviewFileHistory<CR>")
map("n", "<Leader>L", "<Cmd>DiffviewFileHistory %<CR>")
