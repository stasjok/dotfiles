-- Whether I'm at work
local is_at_work = vim.env.USER == "admAsunkinSS"

local function kubernetes_schema_url()
  local schema_path = vim.fs.normalize("~/.kube/json-schema/all.json")
  return vim.fn.filereadable(schema_path) == 1 and schema_path or nil
end

---@param filename string
---@return string?
local function nix_root_dir(filename)
  local root_dir = vim.fs.root(filename, { "flake.nix", ".git" })
  -- 'lib' directory inside nixpkgs repository also contains flake.nix, ignore it
  if root_dir and vim.fs.basename(root_dir) == "lib" then
    root_dir = vim.fs.root(vim.fs.dirname(root_dir), { "flake.nix", ".git" }) or root_dir
  end
  return root_dir
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
    root_dir = nix_root_dir,
    settings = { ["nil"] = { nix = { flake = { nixpkgsInputName = vim.NIL } } } },
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

    ---@param client vim.lsp.Client
    on_init = function(client)
      ---@type lsp.ServerCapabilities
      local overrrides = {
        definitionProvider = false,
        referencesProvider = false,
      }
      -- Override server_capabilities
      client.server_capabilities =
        vim.tbl_deep_extend("force", client.server_capabilities, overrrides)
    end,
  },

  nixd = {
    root_dir = nix_root_dir,

    ---@param config lspconfig.Config
    ---@param root_dir string
    on_new_config = function(config, root_dir)
      local settings = vim.defaulttable()

      local dirname = vim.fs.basename(root_dir)
      local flake = string.format('(builtins.getFlake "git+file:%s")', root_dir)

      -- Default nixpkgs
      settings.nixpkgs.expr =
        '(builtins.getFlake "nixpkgs").legacyPackages.${builtins.currentSystem}'

      -- My dotfiles
      if dirname == "dotfiles" then
        settings.nixpkgs.expr = flake .. ".legacyPackages.${builtins.currentSystem}"
        settings.options["home-manager"].expr = flake .. ".homeConfigurations.stas.options"
      -- Nixpkgs
      elseif dirname == "nixpkgs" then
        settings.nixpkgs.expr = string.format(
          "import %s {localSystem = builtins.currentSystem;}",
          vim.fs.joinpath(root_dir, "pkgs/top-level")
        )
        settings.options.nixos.expr = string.format(
          "(import %s {modules = [];}).options",
          vim.fs.joinpath(root_dir, "nixos/lib/eval-config.nix")
        )
      elseif dirname == "home-manager" then
        settings.options["home-manager"].expr = string.format(
          '(import %s {configuration = {home = {stateVersion = "24.05"; username = "nixd"; homeDirectory = "/home/nixd";};}; pkgs = %s;}).options',
          vim.fs.joinpath(root_dir, "modules"),
          settings.nixpkgs.expr
        )
      end

      config.settings = vim.tbl_deep_extend("force", config.settings or {}, { nixd = settings })
    end,

    ---@param client vim.lsp.Client
    on_init = function(client)
      ---@type lsp.ServerCapabilities
      local overrrides = {
        documentHighlightProvider = false,
        documentSymbolProvider = false,
        hoverProvider = false,
      }
      -- Override server capabilities
      client.server_capabilities =
        vim.tbl_deep_extend("force", client.server_capabilities, overrrides)
      -- Disable semantic tokens
      client.server_capabilities.semanticTokensProvider = nil
    end,
  },

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
  tsserver = {
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
