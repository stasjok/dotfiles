vim.opt.shiftwidth = 2

-- Source current file or selected lines
for _, m in ipairs({ "n", "x" }) do
  vim.api.nvim_buf_set_keymap(0, m, "<LocalLeader>s", ":source<CR>", { noremap = true })
end
