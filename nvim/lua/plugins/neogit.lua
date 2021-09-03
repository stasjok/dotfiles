local map = require("map").map

local neogit = {}

function neogit.config()
  require("neogit").setup({
    disable_commit_confirmation = true,
    integrations = {
      diffview = true,
    },
  })
  -- Mappings
  map("n", "<Leader>g", "<Cmd>lua require('neogit').open()<CR>")
end

return neogit
