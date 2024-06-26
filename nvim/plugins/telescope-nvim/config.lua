local telescope = require("telescope")
local builtin = require("telescope.builtin")
local map = vim.keymap.set

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close,
        ["<C-C>"] = false,
      },
    },
  },
  pickers = {
    buffers = {
      mappings = {
        i = {
          ["<C-E>"] = "delete_buffer",
        },
        n = {
          D = "delete_buffer",
        },
      },
    },
  },
})
telescope.load_extension("fzf")

-- Mappings
local mappings = {
  ["<Leader>R"] = builtin.resume,
  ["<Leader><Space>"] = builtin.buffers,
  ["<Leader>f"] = builtin.find_files,
  ["<Leader>s"] = builtin.live_grep,
  ["<Leader>S"] = builtin.grep_string,
  ["<Leader>;"] = builtin.commands,
  ["<Leader>hh"] = builtin.help_tags,
}

for lhs, rhs in pairs(mappings) do
  map("n", lhs, rhs)
end
