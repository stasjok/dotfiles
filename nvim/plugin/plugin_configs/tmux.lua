local map = require("map").map

-- Configuration
local options = {
  resize = {
    resize_step_x = 2,
    resize_step_y = 2,
  },
}
local logging = {
  file = "disabled",
}
require("tmux").setup(options, logging)

-- Mappings
local mappings = {
  ["<M-h>"] = "move_left()",
  ["<M-j>"] = "move_bottom()",
  ["<M-k>"] = "move_top()",
  ["<M-l>"] = "move_right()",
  ["<M-H>"] = "resize_left()",
  ["<M-J>"] = "resize_bottom()",
  ["<M-K>"] = "resize_top()",
  ["<M-L>"] = "resize_right()",
}
local modes = { "n", "v", "t" }
for lhs, action in pairs(mappings) do
  local rhs = string.format("<Cmd>lua require('tmux').%s<CR>", action)
  map(modes, lhs, rhs)
  -- First leave insert mode, than navigate
  map("i", lhs, "<Esc>" .. rhs)
end
