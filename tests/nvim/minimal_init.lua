-- Reduce the number of scripts loaded
vim.cmd.filetype("off")
vim.cmd.syntax("off")

-- Add test helpers to runtime
vim.opt.runtimepath:prepend("tests/nvim/runtime")
-- Set runtime
require("test.utils").set_rtp()
