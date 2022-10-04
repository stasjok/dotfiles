local tmux = require("tmux")
local map = vim.keymap.set

-- Configuration
local options = {
  copy_sync = {
    enable = false,
  },
  navigation = {
    enable_default_keybindings = false,
  },
  resize = {
    enable_default_keybindings = false,
    resize_step_x = 2,
    resize_step_y = 2,
  },
}
local logging = {
  file = "disabled",
}
tmux.setup(options, logging)

-- Mappings
local mappings = {
  ["<M-h>"] = "move_left",
  ["<M-j>"] = "move_bottom",
  ["<M-k>"] = "move_top",
  ["<M-l>"] = "move_right",
  ["<M-H>"] = "resize_left",
  ["<M-J>"] = "resize_bottom",
  ["<M-K>"] = "resize_top",
  ["<M-L>"] = "resize_right",
}
for lhs, action in pairs(mappings) do
  map({ "n", "v" }, lhs, tmux[action])
  -- First leave insert/terminal mode, then navigate
  local rhs_tmpl = "%s<Cmd>lua require('tmux').%s()<CR>"
  map("i", lhs, string.format(rhs_tmpl, "<Esc>", action))
  map("t", lhs, string.format(rhs_tmpl, "<C-\\><C-N>", action))
end
