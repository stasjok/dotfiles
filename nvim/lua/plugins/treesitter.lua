local treesitter = {}

function treesitter.config()
  -- Add parsers from nix to rtp
  vim.api.nvim_command("packadd nvim-treesitter-parsers")
  require("nvim-treesitter.configs").setup({
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-S>",
        node_incremental = "<C-S>",
        scope_incremental = "<M-s>",
        node_decremental = "<C-Q>",
      },
    },
  })
end

return treesitter
