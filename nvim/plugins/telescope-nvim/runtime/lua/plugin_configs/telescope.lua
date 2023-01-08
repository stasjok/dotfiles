local telescope = require("telescope")
local builtin = require("telescope.builtin")
local map = require("map").map

local M = {}

local config = {
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close,
        ["<C-C>"] = false,
      },
    },
  },
}

local mappings = {
  ["<Leader>R"] = builtin.resume,
  ["<Leader><Space>"] = builtin.buffers,
  ["<Leader>f"] = builtin.find_files,
  ["<Leader>s"] = builtin.live_grep,
  ["<Leader>S"] = builtin.grep_string,
  ["<Leader>;"] = builtin.commands,
  ["<Leader>hh"] = builtin.help_tags,
}

function M.configure()
  telescope.setup(config)
  telescope.load_extension("fzf")

  -- Mappings
  for lhs, rhs in pairs(mappings) do
    map("n", lhs, rhs)
  end
end

return M
