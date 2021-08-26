local map = require("map").map

local surround = {}

function surround.config()
  require("surround").setup({
    load_keymaps = false,
  })
  -- Mappings
  map("n", "ys", "<Cmd>set operatorfunc=SurroundAddOperatorMode<CR>g@")
  map("n", "cs", "<Cmd>lua require('surround').surround_replace()<CR>")
  map("n", "ds", "<Cmd>lua require('surround').surround_delete()<CR>")
  map("n", "cq", "<Cmd>lua require('surround').toggle_quotes()<CR>")
end

return surround
