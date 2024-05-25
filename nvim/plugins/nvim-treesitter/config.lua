---@diagnostic disable-next-line: missing-fields
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
    -- Disable <CR> mapping in cmdwin
    disable = function()
      return vim.fn.win_gettype() == "command"
    end,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "<C-J>", -- <C-Enter>
      node_decremental = "<M-CR>",
    },
  },
})

-- Filetypes
vim.treesitter.language.register("terraform", "terraform-vars")
