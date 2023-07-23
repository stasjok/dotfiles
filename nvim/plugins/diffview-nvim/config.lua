local diffview = require("diffview")

diffview.setup({
  enhanced_diff_hl = true,
  key_bindings = {
    view = {
      q = diffview.close,
    },
    file_panel = {
      q = diffview.close,
    },
  },
})
