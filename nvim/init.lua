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
-- increase mouse scroll speed
for _, m in ipairs{'', 'i', 't'} do
  vim.api.nvim_set_keymap(m, '<ScrollWheelUp>', '<ScrollWheelUp><ScrollWheelUp>', {noremap = true});
  vim.api.nvim_set_keymap(m, '<ScrollWheelDown>', '<ScrollWheelDown><ScrollWheelDown>', {noremap = true});
end
-- automatic yank after mouse selection
vim.api.nvim_set_keymap('v', '<LeftRelease>', '<LeftRelease>"*y', {noremap = true});
-- by default MiddleMouse yanks to unnamed and pastes from * (why?); change yanking also to *
vim.api.nvim_set_keymap('v', '<MiddleMouse>', '"*y<MiddleMouse>', {noremap = true});

-- Clipboard integration with tmux
if vim.env.TMUX then
  vim.g.clipboard = {
    name = 'tmux',
    copy = {
      ['+'] = {'tmux', 'load-buffer', '-w', '-'},
      ['*'] = {'tmux', 'load-buffer', '-w', '-'},
    },
    paste = {
      ['+'] = {'tmux', 'save-buffer', '-'},
      ['*'] = {'tmux', 'save-buffer', '-'},
    },
    cache_enabled = true,
  }
end
