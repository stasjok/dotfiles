vim.cmd([[
augroup terminal
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber sidescrolloff=0
  autocmd TermOpen * startinsert
  autocmd BufWinEnter term://* startinsert
augroup END
]]);

_G.Terminal = {
  Open = function()
    if _G.Terminal.Buffer == nil then
      _G.Terminal.Buffer = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_set_current_buf(_G.Terminal.Buffer)
      vim.fn.termopen('fish', {on_exit = _G.Terminal.OnExit})
    else
      vim.api.nvim_set_current_buf(_G.Terminal.Buffer)
    end
  end,
  OnExit = function()
    vim.api.nvim_buf_delete(_G.Terminal.Buffer, {force = true})
    _G.Terminal.Buffer = nil
  end,
}

vim.api.nvim_set_keymap('n', '<leader>t', '<Cmd>lua _G.Terminal.Open()<CR>', {noremap = true})
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', {noremap = true})
