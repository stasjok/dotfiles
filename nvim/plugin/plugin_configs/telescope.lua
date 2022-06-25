local map = require("map").map

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

require("telescope").load_extension("fzf")

-- Mappings
local mappings = {
  ["<Leader>R"] = "resume()",
  ["<Leader><Space>"] = "buffers()",
  ["<Leader>f"] = "find_files()",
  ["<Leader>s"] = "live_grep()",
  ["<Leader>S"] = "grep_string()",
  ["<Leader>;"] = "commands()",
  ["<Leader>h"] = "help_tags()",
}

for lhs, picker in pairs(mappings) do
  local rhs = string.format("<Cmd>lua require('telescope.builtin').%s<CR>", picker)
  map("n", lhs, rhs)
end
