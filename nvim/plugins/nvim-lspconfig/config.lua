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
    on_new_config = function(new_config, root_dir)
      local formatter_command

      if root_dir:find("nixpkgs", 1, true) then
        formatter_command = { "nixpkgs-fmt" }
      elseif root_dir:find("home-manager", 1, true) then
        formatter_command = { "nixfmt" }
      else
        formatter_command = { "alejandra", "-" }
      end

      new_config.settings = vim.tbl_deep_extend("keep", new_config.settings or {}, {
        ["nil"] = { formatting = { command = formatter_command } },
      })
    end,
  },

  -- Markdown
  marksman = {},
  ltex = {
    filetypes = {
      "markdown",
      "rst",
    },
  },

  -- XML
  lemminx = {},

  -- Terraform
  terraformls = {},

  -- Typescript
  tsserver = {
    cmd = { "typescript-language-server", "--stdio", "--tsserver-path", "tsserver" },
  },

  -- Go
  gopls = {},

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

      return require("lspconfig.server_configurations.rust_analyzer").default_config.root_dir(fname)
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

for lsp_server, config in pairs(lsp_servers) do
  require("lspconfig")[lsp_server].setup(config)
end
