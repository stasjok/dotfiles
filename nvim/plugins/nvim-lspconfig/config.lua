-- Whether I'm at work
local is_at_work = vim.env.USER == "admAsunkinSS"

local function kubernetes_schema_url()
  local schema_path = vim.fs.normalize("~/.kube/json-schema/all.json")
  return vim.fn.filereadable(schema_path) == 1 and schema_path or nil
end

-- List of configured language servers
local lsp_servers = {
  -- Lua
  lua_ls = require("plugin_configs.lspconfig.lua_ls"),

  -- Bash
  bashls = {
    root_dir = function(filename)
      local util = require("lspconfig.util")
      return util.find_git_ancestor(filename) or util.path.dirname(filename)
    end,
  },

  -- Ansible
  ansiblels = {
    filetypes = { "yaml.ansible" },

    root_dir = function(filename)
      local util = require("lspconfig.util")
      return util.root_pattern("ansible.cfg", ".git")(filename) or util.path.dirname(filename)
    end,

    settings = {
      ansible = {
        ansible = {
          useFullyQualifiedCollectionNames = not is_at_work,
        },
        python = {
          interpreterPath = "python3",
        },
        completion = {
          provideRedirectModules = is_at_work,
          provideModuleOptionAliases = true,
        },
      },
    },
  },

  -- JSON
  jsonls = {
    settings = {
      json = {
        -- Need to specify explicitly.
        -- See: https://github.com/b0o/SchemaStore.nvim/issues/8#issuecomment-1129531174
        validate = { enable = true },
        format = { enable = true },
        schemas = {
          {
            fileMatch = {
              "/snippets/*.json",
              "!package.json",
            },
            url = vim.uri_from_fname(
              vim.fs.joinpath(vim.fn.stdpath("config"), "schemas/snippets.json")
            ),
          },
        },
      },
    },
  },

  -- YAML
  yamlls = {
    settings = {
      yaml = {
        customTags = { "!vault" },
        kubernetesSchemaUrl = kubernetes_schema_url(),
        schemas = {
          kubernetes = {
            "/deckhouse/**/*.yml",
            "/deckhouse/**/*.yaml",
            "/kubernetes/**/*.yml",
            "/kubernetes/**/*.yaml",
          },
        },
      },
    },
  },

  -- Python
  pyright = {},

  -- Nix
  nil_ls = {
    root_dir = require("plugin_configs.lspconfig.nixd").root_dir,
    settings = { ["nil"] = { nix = { flake = { nixpkgsInputName = vim.NIL } } } },

    ---@param new_config lspconfig.Config
    ---@param root_dir string
    on_new_config = function(new_config, root_dir)
      local formatter_command

      local dirname = vim.fs.basename(root_dir)
      if dirname == "home-manager" then
        formatter_command = { "nixfmt-classic" }
      else
        formatter_command = { "nixfmt" }
      end

      new_config.settings["nil"].formatting = { command = formatter_command }
    end,

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

  -- Typescript
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio", "--tsserver-path", "tsserver" },
  },

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
