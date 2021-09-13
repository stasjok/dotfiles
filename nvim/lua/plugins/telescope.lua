local map = require("map").map

local telescope = {}

local mappings = {
  ["<Leader><Space>"] = "buffers()",
  ["<Leader>f"] = "find_files()",
  ["<Leader>s"] = "live_grep()",
  ["<Leader>S"] = "grep_string()",
  ["<Leader>;"] = "commands()",
}

function telescope.config()
  require("telescope").setup({
    defaults = {
      mappings = {
        i = {
          ["<Esc>"] = require("telescope.actions").close,
          ["<C-C>"] = false,
        },
      },
    },
  })
  -- Activate telescope-fzf-native installed by nix
  vim.api.nvim_command("packadd telescope-fzf-native-nvim")
  require("telescope").load_extension("fzf")
  -- Mappings
  for lhs, picker in pairs(mappings) do
    local rhs = string.format("<Cmd>lua require('telescope.builtin').%s<CR>", picker)
    map("n", lhs, rhs)
  end
end

telescope.keys = {}
for lhs, _ in pairs(mappings) do
  table.insert(telescope.keys, { "n", lhs })
end

return telescope
