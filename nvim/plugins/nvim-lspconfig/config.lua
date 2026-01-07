-- Override default capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.protocol.make_client_capabilities = function()
  return capabilities
end
