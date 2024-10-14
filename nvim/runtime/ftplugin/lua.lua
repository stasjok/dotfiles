local map = vim.keymap.set

vim.opt.shiftwidth = 2

-- Source current file or selected lines
map({ "n", "x" }, "<LocalLeader>s", ":source<CR>", { buffer = true })
