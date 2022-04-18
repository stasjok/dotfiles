-- Set <Leader> to <Space> and <LocalLeader> to `\`
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Speed up loading Lua modules in Neovim
do
  -- impatient.nvim doesn't work with nix in my case, because it caches
  -- module path. In nix all paths are valid and immutable.
  -- I want to use a separate directory for every instance of neovim.
  -- impatient.nvim uses `vim.fn.stdpath('cache')` to determine cache
  -- directory. I'm using a hack here to temporary change XDG_CACHE_HOME
  -- so that impatient.nvim will use separate directory per nix package.
  local Path = require("plenary.path")
  local orig_cache_dir = vim.env.XDG_CACHE_HOME
  local default_cache_dir = Path:new(vim.env.HOME, ".cache")
  local data_hash = vim.fn.sha256(vim.env.XDG_DATA_DIRS)
  local cache_dir = Path:new(orig_cache_dir or default_cache_dir, "nvim", data_hash)
  if Path:new(cache_dir, "nvim"):mkdir({ mode = 493, parents = true }) then
    vim.env.XDG_CACHE_HOME = tostring(cache_dir)
    require("impatient")
    vim.env.XDG_CACHE_HOME = tostring(orig_cache_dir or default_cache_dir)
  end
end

-- Enable filetype.lua
vim.g.did_load_filetypes = 0
vim.g.do_filetype_lua = 1

-- Clipboard integration with tmux
if vim.env.TMUX then
  vim.g.clipboard = {
    name = "tmux-send-to-clipboard",
    copy = {
      ["+"] = { "tmux", "load-buffer", "-w", "-" },
      ["*"] = { "tmux", "load-buffer", "-w", "-" },
    },
    paste = {
      ["+"] = { "tmux", "save-buffer", "-" },
      ["*"] = { "tmux", "save-buffer", "-" },
    },
    cache_enabled = true,
  }
end

-- Highlight on Yank
vim.cmd([[
augroup highlight_on_yank
autocmd!
autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}
augroup END
]])
