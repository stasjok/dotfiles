do
  local utils = require("utils")
  local api = vim.api
  local lsp = vim.lsp.buf

  local function show_diagnostics()
    local status, existing_float = pcall(api.nvim_buf_get_var, 0, "lsp_floating_preview")
    if status and api.nvim_win_is_valid(existing_float) then
    else
      vim.diagnostic.open_float()
    end
  end

  ---Callback invoked when LSP client attaches to a buffer
  ---@param client integer LSP client ID
  ---@param bufnr integer Buffer number
  local function on_attach(client, bufnr)
    local map = vim.keymap.set
    local telescope_builtin = require("telescope.builtin")

    local function buf_map(mode, lhs, rhs)
      map(mode, lhs, rhs, { buffer = bufnr })
    end

    -- Mappings
    for lhs, rhs in pairs({
      ["gd"] = telescope_builtin.lsp_definitions,
      ["gD"] = lsp.declaration,
      ["<Leader>T"] = lsp.type_definition,
      ["<Leader>i"] = telescope_builtin.lsp_implementations,
      ["gr"] = telescope_builtin.lsp_references,
      ["gs"] = telescope_builtin.lsp_document_symbols,
      ["gS"] = telescope_builtin.lsp_workspace_symbols,
      ["<Leader>r"] = lsp.rename,
      ["K"] = lsp.hover,
      ["<Leader>a"] = lsp.code_action,
      ["<Leader>d"] = function()
        telescope_builtin.diagnostics({ bufnr = 0 })
      end,
      ["<Leader>D"] = telescope_builtin.diagnostics,
      ["]d"] = vim.diagnostic.goto_next,
      ["[d"] = vim.diagnostic.goto_prev,
    }) do
      buf_map("n", lhs, rhs)
    end

    -- Visual mappings
    for lhs, rhs in pairs({
      ["<Leader>a"] = lsp.code_action,
    }) do
      buf_map("x", lhs, rhs)
    end

    -- Show diagnostics automatically
    api.nvim_create_autocmd("CursorHold", {
      desc = "Show diagnostics",
      group = utils.create_augroup("Diagnostics", { buffer = bufnr }),
      buffer = bufnr,
      callback = show_diagnostics,
    })

    -- Document highlight
    if client.supports_method("textDocument/documentHighlight") then
      local hl_augroup = utils.create_augroup("DocumentHighlight", { buffer = bufnr })
      api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        desc = "Document highlights",
        group = hl_augroup,
        buffer = bufnr,
        callback = lsp.document_highlight,
      })
      api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        desc = "Remove document highlights",
        group = hl_augroup,
        buffer = bufnr,
        callback = lsp.clear_references,
      })
    end

    -- Signature help
    require("lsp_signature").on_attach({
      hint_enable = false,
      floating_window_above_first = true,
      hi_parameter = "LspReferenceRead",
    })
  end

  -- Whether I'm at work
  local is_at_work = vim.env.USER == "admAsunkinSS"

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

        return require("lspconfig.server_configurations.rust_analyzer").default_config.root_dir(
          fname
        )
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

  -- Capabilities
  local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities()
  )

  -- Default language server configuration
  local default_config = {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  for lsp_server, config in pairs(lsp_servers) do
    local final_config = vim.tbl_deep_extend("force", default_config, config)
    require("lspconfig")[lsp_server].setup(final_config)
  end
end
