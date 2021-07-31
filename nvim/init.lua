-- Colorscheme (Solarized)
vim.opt.termguicolors = true;
vim.opt.background = 'dark';
vim.api.nvim_command('runtime colors/solarized.lua');

-- Command for installing plugins
vim.cmd [[command! Plugins runtime lua/my/plugins.lua]]

-- Set <leader> to Space and <localleader> to \
vim.g.mapleader = ' ';
vim.g.maplocalleader = '\\';

-- Options
vim.opt.shiftwidth = 4;
vim.opt.softtabstop = -1;
vim.opt.expandtab = true;

vim.opt.mouse = 'a';
vim.opt.hidden = true;
vim.opt.ignorecase = true;
vim.opt.smartcase = true;
vim.opt.ttimeoutlen = 5;
vim.opt_global.scrolloff = 6;
vim.opt_global.sidescrolloff = 6;
vim.opt_global.scrollback = 80000;
vim.opt.lazyredraw = true;

vim.opt.shell = 'bash';

vim.opt.cursorline = true;
vim.opt.number = true;
vim.opt.relativenumber = true;

-- show tabs and trailing spaces
vim.opt.list = true;
vim.opt_global.listchars = 'tab:→ ,trail:⋅,extends:❯,precedes:❮';
-- don't show trailing spaces during insert mode
vim.cmd [[
augroup listchars_in_insert
autocmd!
autocmd InsertEnter * setlocal listchars=tab:→\ ,extends:❯,precedes:❮
autocmd InsertLeave * setlocal listchars=tab:→\ ,trail:⋅,extends:❯,precedes:❮
augroup END
]]

-- Mappings
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
-- by default MiddleMouse paste at the position of cursor in normal mode, but not in insert mode; fix it
vim.api.nvim_set_keymap('i', '<MiddleMouse>', '<LeftMouse><MiddleMouse>', {noremap = true});
-- Emacs-like bindings
vim.api.nvim_set_keymap('!', '<C-b>', '<Left>', {noremap = true})
vim.api.nvim_set_keymap('!', '<C-f>', '<Right>', {noremap = true})
vim.api.nvim_set_keymap('!', '<M-b>', '<C-Left>', {noremap = true})
vim.api.nvim_set_keymap('!', '<M-f>', '<C-Right>', {noremap = true})
vim.api.nvim_set_keymap('i', '<C-n>', '<Down>', {noremap = true})
vim.api.nvim_set_keymap('i', '<C-p>', '<Up>', {noremap = true})
vim.api.nvim_set_keymap('c', '<C-a>', '<C-b>', {noremap = true})
vim.api.nvim_set_keymap('!', '<M-BS>', '<C-w>', {noremap = true})
vim.api.nvim_set_keymap('i', '<M-d>', '<C-o>dw', {noremap = true})
vim.api.nvim_set_keymap('c', '<M-d>', '<C-f>dw<C-c>', {noremap = true})
-- Create new lines in insert mode
vim.api.nvim_set_keymap('i', '<M-n>', '<C-o>o', {noremap = true})
vim.api.nvim_set_keymap('i', '<M-p>', '<C-o>O', {noremap = true})
-- Move lines
vim.api.nvim_set_keymap('n', '<M-d>', '<Cmd>move .+1<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<M-u>', '<Cmd>move .-2<CR>', {noremap = true})
vim.api.nvim_set_keymap('v', '<M-d>', ":move '>+1<CR>gv", {noremap = true})
vim.api.nvim_set_keymap('v', '<M-u>', ":move '<-2<CR>gv", {noremap = true})
-- Shortcuts
vim.api.nvim_set_keymap('n', '<leader>x', '<C-w>v', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>v', '<C-w>s', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>|', '<C-w>|', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>_', '<C-w>_', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>=', '<C-w>=', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>H', '<C-w>H', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>J', '<C-w>J', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>K', '<C-w>K', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>L', '<C-w>L', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader><CR>', '<Cmd>buffer #<CR>', {noremap = true});
vim.api.nvim_set_keymap('n', '<leader>c', '<Cmd>close<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>C', '<Cmd>buffer #<CR><Cmd>bdelete #<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>w', '<Cmd>write<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>W', '<Cmd>wall<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>q', '<Cmd>quit<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>Q', '<Cmd>quitall<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>z', '<Cmd>xit<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>Z', '<Cmd>xall<CR>', {noremap = true})
-- Make j/k movements jumps if count > 5
vim.api.nvim_set_keymap('n', 'j', [[(v:count1 > 5 ? "m'"..v:count : '') .. 'j']], {expr = true, noremap = true})
vim.api.nvim_set_keymap('n', 'k', [[(v:count1 > 5 ? "m'"..v:count : '') .. 'k']], {expr = true, noremap = true})

-- Clipboard integration with tmux
if vim.env.TMUX then
  vim.g.clipboard = {
    name = 'tmux-send-to-clipboard',
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

-- Highlight on Yank
vim.cmd [[
augroup highlight_on_yank
autocmd!
autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}
augroup END
]]
