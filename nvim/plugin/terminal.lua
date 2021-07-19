vim.cmd([[
augroup terminal
  autocmd!
  autocmd TermOpen * lua _G.Terminal.bufnr = vim.fn.winbufnr(0)
  autocmd TermOpen * startinsert
  autocmd BufWinEnter term://* startinsert
augroup END
]]);

_G.Terminal = {
  Open = function()
    if _G.Terminal.bufnr == nil or vim.fn.bufexists(_G.Terminal.bufnr) == 0 then
      return vim.api.nvim_replace_termcodes('<Cmd>terminal<CR>', true, true, true);
    else
      return vim.api.nvim_replace_termcodes('<Cmd>buffer '.._G.Terminal.bufnr..'<CR>', true, true, true);
    end
  end
};

vim.api.nvim_set_keymap('n', '<leader>t', 'v:lua.Terminal.Open()', {expr = true, noremap = true});
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', {noremap = true});
