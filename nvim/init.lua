-- Colorscheme (Solarized)
vim.opt.termguicolors = true;
vim.opt.background = 'dark';
vim.api.nvim_command('colorscheme solarized');

-- Command for installing plugins
vim.cmd [[command! Plugins runtime lua/my/plugins.lua]]

-- Options
vim.opt.hidden = true;
vim.opt.ignorecase = true;
vim.opt.smartcase = true;
