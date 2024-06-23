require("surround").setup({
  mappings_style = "surround",
  map_insert_mode = false,
  space_on_closing_char = true,
})

-- Mappings
vim.keymap.del("x", "s")
vim.keymap.set("x", "<Leader>s", "<Esc>gv<Cmd>lua require('surround').surround_add()<CR>")
