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
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "<C-J>", -- <C-Enter>
      node_decremental = "<M-CR>",
    },
  },
})
