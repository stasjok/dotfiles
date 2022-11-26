require("utils").set_rtp()

-- Set <Leader> to <Space> and <LocalLeader> to `\`
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Speed up loading Lua modules in Neovim
do
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
  pcall(require, "impatient")
end

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
      custom_highlights = function(_)
        return {
          TermCursor = { bg = "#179299" },
          ["@text.diff.add"] = { link = "diffAdded" },
          ["@text.diff.delete"] = { link = "diffRemoved" },
        }
      end,
    })

    catppuccin.load()
  end
end

-- Clipboard integration with tmux
-- TODO: should be default in neovim 0.9
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

-- Highlight a selection on Yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_on_yank", {}),
  callback = function()
    vim.highlight.on_yank()
  end,
})
