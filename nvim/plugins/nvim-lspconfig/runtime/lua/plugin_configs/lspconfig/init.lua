local utils = require("plugin_configs.lspconfig.utils")

local M = {}

-- Capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- List of configured language servers
local lsp_servers = {
  "lua_ls",
  "bashls",
  "ansiblels",
  "jsonls",
  "yamlls",
  "pyright",
  "nil_ls",
  "marksman",
  "ltex",
  "lemminx",
  "terraformls",
  "tsserver",
  "gopls",
  "rust_analyzer",
  "taplo",
  "clangd",
}

-- Default language server configuration
local default_config = {
  on_attach = utils.on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 100,
  },
}

function M.configure()
  for _, lsp_server in ipairs(lsp_servers) do
    local status, config = pcall(require, "plugin_configs.lspconfig." .. lsp_server)
    local final_config = default_config
    if status then
      final_config = vim.tbl_deep_extend("force", default_config, config)
    end
    require("lspconfig")[lsp_server].setup(final_config)
  end
end

return M
