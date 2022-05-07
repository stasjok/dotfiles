local on_attach = require("plugin_configs.lspconfig.utils").on_attach

local luadev = require("lua-dev").setup({
  lspconfig = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        completion = { callSnippet = "Disable" },
      },
    },
    on_attach = function(client, buffer)
      on_attach(client, buffer)
      client.resolved_capabilities.document_formatting = false
    end,
  },
})

return luadev
