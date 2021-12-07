local treesitter = {}

function treesitter.config()
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
