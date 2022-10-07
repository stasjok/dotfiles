local test_directory = require("plenary.test_harness").test_directory
local map = vim.keymap.set
local buf_get_name = vim.api.nvim_buf_get_name

vim.opt.shiftwidth = 2

local buf_name = buf_get_name(0) --[[@as string]]

-- Source current file or selected lines
map({ "n", "x" }, "<LocalLeader>s", ":source<CR>", { buffer = true })
if buf_name:sub(-9, #buf_name) == "_spec.lua" then
  -- Test current spec file
  map("n", "<LocalLeader>r", function()
    test_directory(buf_name, { minimal_init = "NORC" })
  end, { buffer = true })
end
