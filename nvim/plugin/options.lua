-- Default indentation settings
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.opt.expandtab = true

-- Options
vim.opt.termguicolors = true
vim.opt.mouse = "a"

-- Make <Esc> faster
vim.opt.ttimeoutlen = 5
vim.opt.timeoutlen = 500

-- Don't redraw the screen while executing macros
vim.opt.lazyredraw = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Gutter settings
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Make some context visible
vim.opt_global.scrolloff = 6
vim.opt_global.sidescrolloff = 6

-- Terminal buffer limit
vim.opt_global.scrollback = 80000

-- Fire CursorHold event faster
vim.opt.updatetime = 250

-- Use bash as default shell (it's faster)
vim.opt.shell = "bash"

-- Show tabs and trailing spaces
vim.opt.list = true
vim.opt_global.listchars = "tab:→ ,trail:⋅,extends:❯,precedes:❮"
-- Don't show trailing spaces during insert mode
vim.cmd([[
augroup listchars_update
  autocmd!
  autocmd InsertEnter * setlocal listchars=tab:→\ ,extends:❯,precedes:❮
  autocmd InsertLeave * setlocal listchars=tab:→\ ,trail:⋅,extends:❯,precedes:❮
augroup END
]])
