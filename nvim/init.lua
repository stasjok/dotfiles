require("utils").set_rtp()

-- Set <Leader> to <Space> and <LocalLeader> to `\`
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Speed up loading Lua modules in Neovim
local luacache_suffix = vim.fn.sha256(vim.o.runtimepath):sub(1, 7)
local stdcache = vim.fn.stdpath("cache")
_G.__luacache_config = {
  chunks = {
    enable = true,
    path = string.format("%s/luacache_chunks_%s", stdcache, luacache_suffix),
  },
  modpaths = {
    enable = true,
    path = string.format("%s/luacache_modpaths_%s", stdcache, luacache_suffix),
  },
}
require("impatient")

-- Colorscheme
do
  local status, catppuccin = pcall(require, "catppuccin")

  if status then
    catppuccin.setup({
      flavour = "macchiato",
      background = {
        light = "latte",
        dark = "macchiato",
      },
      styles = {
        conditionals = {},
        keywords = { "italic" },
      },
      integrations = {
        -- Disable default
        nvimtree = false,
        dashboard = false,
        indent_blankline = false,
        -- Enable optional
        mini = true,
      },
      custom_highlights = {
        TermCursor = { bg = "#179299" },
      },
    })

    catppuccin.load()
  end
end

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
