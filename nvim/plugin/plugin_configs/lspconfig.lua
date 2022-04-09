local utils = require("plugin_configs.lspconfig.utils")
local diagnostics = require("null-ls").builtins.diagnostics
local formatting = require("null-ls").builtins.formatting

-- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- Configuration of null-ls
require("null-ls").setup({
  sources = {
    diagnostics.shellcheck,
    formatting.shfmt,
    formatting.stylua,
    formatting.black,
  },
})

-- List of configured language servers
local lsp_servers = {
  "null-ls",
  "sumneko_lua",
  "bashls",
  "ansiblels",
  "jsonls",
  "pyright",
  "rnix",
  "terraformls",
}

-- Default language server configuration
local default_config = {
  on_attach = utils.on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 100,
  },
}

for _, lsp_server in ipairs(lsp_servers) do
  local status, config = pcall(require, "plugin_configs.lspconfig." .. lsp_server)
  local final_config = default_config
  if status then
    final_config = vim.tbl_deep_extend("force", default_config, config)
  end
  require("lspconfig")[lsp_server].setup(final_config)
end
