local treesitter = {}

function treesitter.config()
  require("nvim-treesitter.configs").setup({
    highlight = {
      enable = true,
      disable = function(_, _)
        return vim.bo.filetype == "yaml.ansible"
      end,
    },
    indent = {
      enable = true,
      disable = { "yaml" },
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
