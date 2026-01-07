-- Whether I'm at work
local is_at_work = vim.env.USER == "admAsunkinSS"

-- List of configured language servers
local lsp_servers = {
  -- Nix
  nil_ls = {
    root_dir = require("plugin_configs.lspconfig.nixd").root_dir,
    settings = { ["nil"] = { nix = { flake = { nixpkgsInputName = vim.NIL } } } },

    ---@param client vim.lsp.Client
    on_init = function(client)
      client.server_capabilities.definitionProvider = false
      client.server_capabilities.referencesProvider = false
      client.server_capabilities.hoverProvider = false
    end,
  },

  nixd = require("plugin_configs.lspconfig.nixd"),

  -- Markdown
  marksman = {},
  ltex = {
    filetypes = {
      "markdown",
      "rst",
    },
    autostart = false,
  },

  -- XML
  lemminx = {},

  -- Terraform
  terraformls = {},

  -- Go
  gopls = {
    settings = {
      gopls = {
        ["ui.semanticTokens"] = true,
        ["ui.noSemanticString"] = true,
        ["ui.noSemanticNumber"] = true,
        ["ui.diagnostic.staticcheck"] = true,
      },
    },
  },

  -- Rust
  rust_analyzer = {
    root_dir = function(fname)
      -- Re-use language server for libraries
      if fname:sub(1, 11) == "/nix/store/" or fname:find("/.cargo/registry/src/", 5, true) then
        local clients = vim.lsp.get_active_clients({ name = "rust_analyzer" })
        if clients[1] then
          return clients[1].config.root_dir
        end
      end

      return require("lspconfig.configs.rust_analyzer").default_config.root_dir(fname)
    end,
  },

  -- TOML
  taplo = {
    settings = {
      formatter = {
        arrayAutoCollapse = false,
      },
    },
  },

  -- C
  clangd = {},
}

-- Override default capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.protocol.make_client_capabilities = function()
  return capabilities
end

for lsp_server, config in pairs(lsp_servers) do
  require("lspconfig")[lsp_server].setup(config)
end
