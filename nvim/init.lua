-- Colorscheme (Solarized)
vim.opt.termguicolors = true;
vim.opt.background = 'dark';
vim.api.nvim_command('colorscheme solarized');

-- Command for installing plugins
vim.cmd [[command! Plugins runtime lua/my/plugins.lua]]

-- Set <leader> to Space and <localleader> to \
vim.g.mapleader = ' ';
vim.g.maplocalleader = '\\';

-- Options
vim.opt.mouse = 'a';
vim.opt.hidden = true;
vim.opt.ignorecase = true;
vim.opt.smartcase = true;
vim.opt.ttimeoutlen = 5;

-- Mappings
vim.api.nvim_set_keymap('n', '<leader><CR>', '<Cmd>buffer #<CR>', {noremap = true});
function _G.OnEnter()
  if vim.v.hlsearch == 1 then
    return vim.api.nvim_replace_termcodes('<Cmd>nohlsearch<CR>', true, true, true);
  else
    return vim.api.nvim_replace_termcodes('<CR>', true, true, true);
  end
end
vim.api.nvim_set_keymap('n', '<CR>', 'v:lua.OnEnter()', {expr = true, noremap = true});

-- Clipboard integration with tmux
if vim.env.TMUX then
  vim.g.clipboard = {
    name = 'tmux',
    copy = {
      ['+'] = {'tmux', 'load-buffer', '-w', '-'},
      ['*'] = {'tmux', 'load-buffer', '-w', '-'},
    },
    paste = {
      ['+'] = {'tmux', 'save-buffer', '-w', '-'},
      ['*'] = {'tmux', 'save-buffer', '-w', '-'},
    },
    cache_enabled = 1,
  }
end
