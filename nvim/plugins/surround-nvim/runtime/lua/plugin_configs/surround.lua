local map = require("map").map
local del_map = vim.api.nvim_del_keymap

local M = {}

local config = {
  mappings_style = "surround",
  map_insert_mode = false,
  space_on_closing_char = true,
}

function M.configure()
  require("surround").setup(config)

  -- Mappings
  del_map("x", "s")
  map("x", "<Leader>s", "<Esc>gv<Cmd>lua require('surround').surround_add()<CR>")
end

return M
