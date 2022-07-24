local lspconfig = require("lspconfig")
local lsputil = require("lspconfig.util")
local map = vim.keymap.set
local buf_get_name = vim.api.nvim_buf_get_name
local create_augroup = vim.api.nvim_create_augroup
local clear_autocmds = vim.api.nvim_clear_autocmds
local create_autocmd = vim.api.nvim_create_autocmd
local formatting_sync = vim.lsp.buf.formatting_sync

vim.opt.shiftwidth = 2

-- Source current file or selected lines
map({ "n", "x" }, "<LocalLeader>s", ":source<CR>", { buffer = true })

-- Auto-format on save
local root_dir = lspconfig["sumneko_lua"].get_root_dir(buf_get_name(0))
local stylua_conf_exists = root_dir
  and (
    lsputil.path.exists(root_dir .. "/stylua.toml")
    or lsputil.path.exists(root_dir .. "/.stylua.toml")
  )

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
