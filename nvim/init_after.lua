-- Highlight a selection on Yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_on_yank", {}),
  callback = function()
    vim.highlight.on_yank()
  end,
})
