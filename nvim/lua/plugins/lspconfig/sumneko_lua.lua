local luadev = require("lua-dev").setup({
  lspconfig = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        completion = { callSnippet = "Disable" },
      },
    },
  },
})

return luadev
