local yamlls = {}
local on_attach = require("plugin_configs.lspconfig.utils").on_attach

yamlls.settings = {}

yamlls.on_attach = function(client, buffer)
  on_attach(client, buffer)
  -- Need to dynamically register document_formatting capability
  -- https://github.com/redhat-developer/yaml-language-server/issues/486
  client.resolved_capabilities.document_formatting = true
end

return yamlls
