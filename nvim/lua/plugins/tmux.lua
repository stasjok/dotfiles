local map = require("map").map

local tmux = {}

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

function tmux.config()
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
  for lhs, action in pairs(mappings) do
    local rhs = string.format("<Cmd>lua require('tmux').%s<CR>", action)
    map(modes, lhs, rhs)
    -- First leave insert mode, than navigate
    map("i", lhs, "<Esc>" .. rhs)
  end
end

-- Keybindings for lazy-loading
tmux.keys = {}
table.insert(modes, "i")
for key, _ in pairs(mappings) do
  for _, mode in ipairs(modes) do
    table.insert(tmux.keys, { mode, key })
  end
end

return tmux
