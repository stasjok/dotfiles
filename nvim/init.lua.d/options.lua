local vim = vim
local api = vim.api
local o = vim.o

-- Default indentation settings
o.shiftwidth = 4
o.softtabstop = -1
o.expandtab = true

-- Options
o.mouse = "a"

-- Make <Esc> faster
o.ttimeoutlen = 5
o.timeoutlen = 700

-- Don't redraw the screen while executing macros
o.lazyredraw = true

-- Search settings
o.ignorecase = true
o.smartcase = true

-- Gutter settings
o.cursorline = true
o.number = true
o.relativenumber = true
o.signcolumn = "yes"

-- Make some context visible
o.scrolloff = 6
o.sidescrolloff = 6

-- Terminal buffer limit
o.scrollback = 80000

-- Fire CursorHold event faster
o.updatetime = 300

-- Use system bash as default shell (it's faster)
o.shell = vim.uv.fs_stat("/bin/bash") and "/bin/bash" or "bash"

-- Show tabs and trailing spaces
o.list = true
o.listchars = "tab:→ ,trail:⋅,extends:❯,precedes:❮"

-- Don't show trailing spaces during insert mode
local augroup = api.nvim_create_augroup("listchars_update", {})
api.nvim_create_autocmd("InsertEnter", {
  desc = "Set 'listchars' to not show trailing spaces",
  group = augroup,
  command = "setlocal listchars-=trail:⋅",
})
api.nvim_create_autocmd("InsertLeave", {
  desc = "Set 'listchars' to show trailing spaces",
  group = augroup,
  command = "setlocal listchars+=trail:⋅",
})

-- Find out when something is changing `scrolloff` to 0
-- TODO: remove this autocmd when the culprit is found
api.nvim_create_autocmd("OptionSet", {
  pattern = "scrolloff",
  callback = function(args)
    vim.notify(
      string.format(
        "Option '%s' changed from %s to %s using %s command.",
        args.match,
        vim.v.option_old,
        vim.v.option_new,
        vim.v.option_command
      )
    )
  end,
})
