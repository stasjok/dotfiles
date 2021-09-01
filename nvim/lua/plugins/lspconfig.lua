local utils = require("plugins.lspconfig.utils")

local lspconfig = {}

function lspconfig.config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

  -- Diagnostics settings
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      virtual_text = false,
      update_in_insert = true,
    }
  )

  -- Diagnostics icons
  local signs = {
    Error = " ",
    Warning = " ",
    Hint = " ",
    Information = " ",
  }
  for type, icon in pairs(signs) do
    local hl = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  local luadev = require("lua-dev").setup({
    lspconfig = {
      cmd = { "lua-language-server" },
      on_attach = utils.on_attach,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 100,
      },
    },
  })
  require("lspconfig").sumneko_lua.setup(luadev)

  require("lspconfig")["bashls"].setup({
    on_attach = utils.on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 100,
    },
    root_dir = function(filename)
      return require("lspconfig.util").root_pattern(".git")(filename)
        or require("lspconfig.util").path.dirname(filename)
    end,
  })

  require("lspconfig")["ansiblels"].setup({
    filetypes = { "yaml.ansible" },
    on_attach = utils.on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 100,
    },
    root_dir = function(filename)
      return require("lspconfig.util").root_pattern("ansible.cfg", ".git")(filename)
        or require("lspconfig.util").path.dirname(filename)
    end,
    settings = {
      ansible = {
        ansible = {
          useFullyQualifiedCollectionNames = false,
        },
        ansibleLint = {
          arguments = "",
        },
      },
    },
  })

  require("lspconfig")["jsonls"].setup({
    on_attach = utils.on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 100,
    },
    settings = {
      json = {
        schemas = {
          {
            fileMatch = {
              "/nvim/snippets/*.json",
              "!package.json",
            },
            schema = {
              allowComments = false,
              allowTrailingCommas = false,
              type = "object",
              description = "User snippet configuration",
              defaultSnippets = {
                {
                  label = "Empty snippet",
                  body = {
                    ["${1:snippetName}"] = {
                      prefix = "${2:prefix}",
                      body = "${3:snippet}",
                      description = "${4:description}",
                    },
                  },
                },
              },
              additionalProperties = {
                type = "object",
                required = { "body" },
                additionalProperties = false,
                defaultSnippets = {
                  {
                    label = "Snippet",
                    body = {
                      prefix = "${1:prefix}",
                      body = "${2:snippet}",
                      description = "${3:description}",
                    },
                  },
                },
                properties = {
                  prefix = {
                    description = "The prefix to use when selecting the snippet in intellisense",
                    type = { "string", "array" },
                  },
                  body = {
                    markdownDescription = "The snippet content. Use `$1`, `${1:defaultText}` to define cursor positions, use `$0` for the final cursor position. Insert variable values with `${varName}` and `${varName:defaultText}`, e.g. `This is file: $TM_FILENAME`.",
                    type = { "string", "array" },
                    items = { type = "string" },
                  },
                  description = {
                    description = "The snippet description.",
                    type = { "string", "array" },
                  },
                },
              },
            },
          },
        },
      },
    },
  })

  for _, lsp_server in ipairs({ "pyright" }) do
    require("lspconfig")[lsp_server].setup({
      on_attach = utils.on_attach,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 100,
      },
    })
  end
end

return lspconfig
