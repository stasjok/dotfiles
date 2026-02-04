if vim.b.did_ftplugin_lua then
  return
end
vim.b.did_ftplugin_lua = true

-- Conceal in markdown help files
if vim.bo.buftype == "help" then
  vim.wo[0][0].conceallevel = 2
  vim.wo[0][0].concealcursor = "nc"

  -- Ensure correct window options are set
  vim.api.nvim_create_autocmd("BufWinEnter", {
    buffer = 0,
    group = require("utils").create_augroup("help_options", { buffer = 0, clear = true }),
    command = "setlocal scrolloff< sidescrolloff< signcolumn=auto nonumber norelativenumber nolist",
  })
end
