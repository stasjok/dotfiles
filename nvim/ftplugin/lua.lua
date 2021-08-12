local lspconfig = require("lspconfig")
local lsputil = require("lspconfig.util")

vim.opt.shiftwidth = 2

-- Source current file or selected lines
for _, m in ipairs({ "n", "x" }) do
  vim.api.nvim_buf_set_keymap(0, m, "<LocalLeader>s", ":source<CR>", { noremap = true })
end

-- Auto-format on save
local root_dir = lspconfig["null-ls"].get_root_dir(vim.api.nvim_buf_get_name(0))
local stylua_conf_exists = lsputil.path.exists(root_dir .. "/stylua.toml")
  or lsputil.path.exists(root_dir .. "/.stylua.toml")

if stylua_conf_exists then
  vim.cmd([[
    augroup LuaAutoFormatting
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
    augroup END
  ]])
end
