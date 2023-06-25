-- smart-splits.nvim
do
  local smart_splits = require("smart-splits")
  local map = vim.keymap.set

  -- Configuration
  smart_splits.setup({
    -- the default number of lines/columns to resize by at a time
    default_amount = 2,

    log_level = "error",
  })

  -- Mappings
  for lhs, action in pairs({
    ["<M-h>"] = "move_cursor_left",
    ["<M-j>"] = "move_cursor_down",
    ["<M-k>"] = "move_cursor_up",
    ["<M-l>"] = "move_cursor_right",
  }) do
    map("n", lhs, smart_splits[action])

    -- First leave insert/visual/terminal mode, then move
    map({ "i", "t" }, lhs, function()
      vim.cmd.stopinsert()
      smart_splits[action]()
    end)
    map("v", lhs, function()
      vim.api.nvim_feedkeys(vim.keycode("<C-\\><C-N>"), "nx", false)
      smart_splits[action]()
    end)
  end

  map({ "n", "v", "i", "t" }, "<M-H>", smart_splits.resize_left)
  map({ "n", "v", "i", "t" }, "<M-J>", smart_splits.resize_down)
  map({ "n", "v", "i", "t" }, "<M-K>", smart_splits.resize_up)
  map({ "n", "v", "i", "t" }, "<M-L>", smart_splits.resize_right)
end
