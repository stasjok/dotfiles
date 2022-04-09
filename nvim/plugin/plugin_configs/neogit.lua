local map = require("map").map

require("neogit").setup({
  disable_commit_confirmation = true,
  disable_builtin_notifications = true,
  disable_insert_on_commit = false,
  integrations = {
    diffview = true,
  },
})

-- Mappings
map("n", "<Leader>g", "<Cmd>lua require('neogit').open()<CR>")
