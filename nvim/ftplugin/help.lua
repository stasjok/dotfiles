if vim.b.did_ftplugin_lua then
  return
end
vim.b.did_ftplugin_lua = true

-- Ensure correct window options are set
vim.api.nvim_create_autocmd("BufWinEnter", {
  buffer = 0,
  group = require("utils").create_augroup("help_options", { buffer = 0, clear = true }),
  command = "setlocal scrolloff< sidescrolloff< signcolumn=auto nonumber norelativenumber nolist",
})
