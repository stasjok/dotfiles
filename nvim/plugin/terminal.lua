vim.cmd([[
augroup terminal
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber sidescrolloff=0 | startinsert
augroup END
]]);

_G.Terminal = {
  Open = function()
    if _G.TerminalBuffer == nil or not vim.api.nvim_buf_is_valid(_G.TerminalBuffer) then
      _G.TerminalBuffer = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_set_current_buf(_G.TerminalBuffer)
      vim.fn.termopen('fish', {on_exit = _G.Terminal.OnExit})
      vim.api.nvim_command('startinsert')
    else
      vim.api.nvim_set_current_buf(_G.TerminalBuffer)
      vim.api.nvim_command('startinsert')
    end
  end,
  OnExit = function()
    vim.api.nvim_buf_delete(_G.TerminalBuffer, {force = true})
    _G.TerminalBuffer = nil
  end,
}

vim.api.nvim_set_keymap('n', '<leader>t', '<Cmd>lua _G.Terminal.Open()<CR>', {noremap = true})
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', {noremap = true})
