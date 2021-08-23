local map = require("map").map

local tmux = {}

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
  local mappings = {
    ["<M-h>"] = "<Cmd>lua require('tmux').move_left()<CR>",
    ["<M-j>"] = "<Cmd>lua require('tmux').move_bottom()<CR>",
    ["<M-k>"] = "<Cmd>lua require('tmux').move_top()<CR>",
    ["<M-l>"] = "<Cmd>lua require('tmux').move_right()<CR>",
    ["<M-H>"] = "<Cmd>lua require('tmux').resize_left()<CR>",
    ["<M-J>"] = "<Cmd>lua require('tmux').resize_bottom()<CR>",
    ["<M-K>"] = "<Cmd>lua require('tmux').resize_top()<CR>",
    ["<M-L>"] = "<Cmd>lua require('tmux').resize_right()<CR>",
  }
  for lhs, rhs in pairs(mappings) do
    map({ "n", "v", "t" }, lhs, rhs)
    -- First leave insert mode, than navigate
    map("i", lhs, "<Esc>" .. rhs)
  end
end

return tmux
