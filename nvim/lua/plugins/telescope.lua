local map = require("map").map

local telescope = {}

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
  vim.cmd("packadd telescope-fzf-native-nvim")
  require("telescope").load_extension("fzf")
  -- Mappings
  map("n", "<Leader><Space>", "<Cmd>lua require('telescope.builtin').buffers()<CR>")
  map("n", "<Leader>f", "<Cmd>lua require('telescope.builtin').find_files()<CR>")
  map("n", "<Leader>s", "<Cmd>lua require('telescope.builtin').live_grep()<CR>")
  map("n", "<Leader>S", "<Cmd>lua require('telescope.builtin').grep_string()<CR>")
  map("n", "<Leader>;", "<Cmd>lua require('telescope.builtin').commands()<CR>")
end

return telescope
