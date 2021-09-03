local luadev = require("lua-dev").setup({
  lspconfig = {
    cmd = { "lua-language-server" },
  },
})

return luadev
