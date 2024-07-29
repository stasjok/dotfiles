-- Reduce the number of scripts loaded
vim.g.did_load_filetypes = 1
vim.cmd.syntax("off")

-- Add test helpers to runtime
vim.opt.runtimepath:prepend("tests/nvim")
-- Set runtime
require("test.utils").set_rtp()
