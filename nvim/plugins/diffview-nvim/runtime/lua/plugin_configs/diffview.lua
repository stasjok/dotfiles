local diffview = require("diffview")

local M = {}

local config = {
  enhanced_diff_hl = true,
  key_bindings = {
    view = {
      q = diffview.close,
    },
    file_panel = {
      q = diffview.close,
    },
  },
}

function M.configure()
  diffview.setup(config)
end

return M
