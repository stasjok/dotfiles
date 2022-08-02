local lsputil = require("lspconfig.util")
local test_directory = require("plenary.test_harness").test_directory
local map = vim.keymap.set
local buf_get_name = vim.api.nvim_buf_get_name
local create_augroup = vim.api.nvim_create_augroup
local clear_autocmds = vim.api.nvim_clear_autocmds
local create_autocmd = vim.api.nvim_create_autocmd
local formatting_sync = vim.lsp.buf.formatting_sync

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

-- Auto-format on save
-- TODO: Use vim.fs from 0.8
local stylua_conf_exists = lsputil.root_pattern(".stylua.toml", "stylua.toml")(buf_name)
if stylua_conf_exists then
  local augroup = create_augroup("LuaAutoFormat", { clear = false })
  clear_autocmds({ group = augroup, buffer = 0 })
  create_autocmd("BufWritePre", {
    desc = "Format on save",
    group = augroup,
    buffer = 0,
    callback = function()
      formatting_sync({}, 1000)
    end,
  })
end
