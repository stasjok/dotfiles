vim.api.nvim_command("packadd packer.nvim")

local packer = require("packer")
local join_paths = require("packer.util").join_paths

packer.startup({

  -- Packer configuration
  config = {
    compile_path = join_paths(vim.fn.stdpath("data"), "site", "plugin", "packer_compiled.lua"),
    auto_reload_compiled = false,
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "rounded" })
      end,
    },
    profile = {
      enable = true,
    },
  },

  -- Plugin specifications
  {
    -- Docs
    "nanotee/nvim-lua-guide",
    "nanotee/luv-vimdocs",

    -- Libraries
    { "nvim-lua/plenary.nvim", commit = "15c3cb9e6311dc1a875eacb9fc8df69ca48d7402" },
    { "tjdevries/lazy.nvim", commit = "238c1b9a661947b864a7d103f9d6b1f376c3b72f" },

    -- Color schemes
    {
      "ful1e5/onedark.nvim",
      commit = "5efacc13479cda116cac11e271d397c92fb07db5",
      config = function()
        require("plugins.onedark").config()
      end,
    },

    -- File icons
    { "kyazdani42/nvim-web-devicons", commit = "da717e19678bd6ec33008cf92da05da1b8ceb87d" },

    -- Text objects surrounding
    {
      "blackCauldron7/surround.nvim",
      commit = "5c7fd08947968c296f37f1dad2ecbda52dd05792",
      keys = {
        { "n", "ys" },
        { "n", "cs" },
        { "n", "ds" },
        { "n", "cq" },
      },
      config = function()
        require("plugins.surround").config()
      end,
    },

    -- Auto-pairs
    {
      "windwp/nvim-autopairs",
      commit = "afd3b224a0d508af38270dc87d836fc55b347561",
      event = "InsertEnter",
      config = function()
        require("plugins.autopairs").config()
      end,
    },

    -- Comments toggle
    {
      "b3nj5m1n/kommentary",
      commit = "a5d7cd90059ad99b5e80a1d40d655756d86b5dad",
      keys = {
        { "n", "gc" },
        { "x", "gc" },
      },
    },

    -- Snippets
    {
      "L3MON4D3/LuaSnip",
      commit = "4cba5fa1e8d8bc3e367a0b414699efdf1f2443eb",
      config = function()
        require("plugins.luasnip").config()
      end,
    },

    -- Tree-sitter
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "0.5-compat",
      commit = "27f5e99cdd1b4e7f6a5cc30016d990ebf81a561c",
      config = function()
        require("plugins.treesitter").config()
      end,
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      commit = "50e5e86ac37ee3989a0015d3934c5a961012990a",
      cmd = "Telescope",
      keys = require("plugins.telescope").keys,
      module = "telescope",
      config = function()
        require("plugins.telescope").config()
      end,
    },

    -- EditorConfig
    {
      "editorconfig/editorconfig-vim",
      commit = "3078cd10b28904e57d878c0d0dab42aa0a9fdc89",
      config = function()
        require("plugins.editorconfig").config()
      end,
    },

    -- Tmux integration
    {
      "aserowy/tmux.nvim",
      commit = "e5eebe69577e40477996166f77a858c6708fc4fe",
      keys = require("plugins.tmux").keys,
      config = function()
        require("plugins.tmux").config()
      end,
    },

    -- Auto completion
    {
      "hrsh7th/nvim-compe",
      commit = "73529ce61611c9ee3821e18ecc929c422416c462",
      config = function()
        require("compe").setup({
          source = {
            nvim_lsp = true,
            luasnip = true,
            buffer = true,
            path = true,
          },
        })
        vim.opt.completeopt = { "menuone", "noselect" }

        _G.complete_show_confirm = function(key)
          if vim.fn.pumvisible() == 1 then
            return vim.fn["compe#confirm"]()
          else
            return vim.fn["compe#complete"]()
          end
        end

        vim.api.nvim_set_keymap(
          "i",
          "<C-y>",
          "v:lua.complete_show_confirm()",
          { expr = true, noremap = true }
        )
        -- without extra <C-e> keys like <C-n>/<C-p> doesn't work, don't know why
        vim.api.nvim_set_keymap(
          "i",
          "<C-e>",
          '<Cmd>lua require"compe"._close()<CR><C-e>',
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "i",
          "<M-d>",
          'compe#scroll({ "delta": +8 })',
          { expr = true, noremap = true }
        )
        vim.api.nvim_set_keymap(
          "i",
          "<M-u>",
          'compe#scroll({ "delta": -8 })',
          { expr = true, noremap = true }
        )
        _G.tab_complete = function()
          if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
          else
            return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
          end
        end
        _G.s_tab_complete = function()
          if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes("<C-p>", true, false, true)
          else
            return vim.api.nvim_replace_termcodes("<C-d>", true, false, true)
          end
        end
        vim.api.nvim_set_keymap(
          "i",
          "<Tab>",
          "v:lua.tab_complete()",
          { expr = true, noremap = true }
        )
        vim.api.nvim_set_keymap(
          "i",
          "<S-Tab>",
          "v:lua.s_tab_complete()",
          { expr = true, noremap = true }
        )
      end,
    },

    {
      "neovim/nvim-lspconfig",
      commit = "662159eeb112c076d90b2c3fe799f16a8165e4a6",
      config = function()
        local on_attach = function(client, bufnr)
          for lhs, rhs in pairs({
            gd = '<Cmd>lua require("telescope.builtin").lsp_definitions()<CR>',
            gD = "<Cmd>lua vim.lsp.buf.declaration()<CR>",
            ["<leader>T"] = "<Cmd>lua vim.lsp.buf.type_definition()<CR>",
            ["<leader>i"] = '<Cmd>lua require("telescope.builtin").lsp_implementations()<CR>',
            gr = '<Cmd>lua require("telescope.builtin").lsp_references()<CR>',
            gs = '<Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>',
            gS = '<Cmd>lua require("telescope.builtin").lsp_workspace_symbols()<CR>',
            ["<leader>r"] = "<Cmd>lua vim.lsp.buf.rename()<CR>",
            K = "<Cmd>lua vim.lsp.buf.hover()<CR>",
            ["<leader>a"] = "<Cmd>lua vim.lsp.buf.code_action()<CR>",
            ["<leader>d"] = '<Cmd>lua require("telescope.builtin").lsp_document_diagnostics()<CR>',
            ["<leader>D"] = '<Cmd>lua require("telescope.builtin").lsp_workspace_diagnostics()<CR>',
            ["]d"] = "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
            ["[d"] = "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>",
            ["<leader>F"] = "<Cmd>lua vim.lsp.buf.formatting()<CR>",
          }) do
            vim.api.nvim_buf_set_keymap(bufnr, "n", lhs, rhs, { noremap = true })
          end

          vim.api.nvim_buf_set_keymap(
            bufnr,
            "x",
            "<leader>F",
            ":lua vim.lsp.buf.range_formatting()<CR>",
            { noremap = true, silent = true }
          )

          function _G._show_diagnostics(opts)
            local status, existing_float = pcall(
              vim.api.nvim_buf_get_var,
              0,
              "lsp_floating_preview"
            )
            if status and vim.api.nvim_win_is_valid(existing_float) then
            else
              vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })
            end
          end

          -- Show diagnostics automatically
          vim.cmd([[
            augroup ShowDiagnostics
            autocmd! * <buffer>
            autocmd CursorHold,CursorHoldI <buffer> lua _G._show_diagnostics()
            augroup END
          ]])

          -- Document highlight
          if client.supports_method("textDocument/documentHighlight") then
            vim.cmd([[
              augroup DocumentHighlight
              autocmd! * <buffer>
              autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
              autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
              autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]])
          end

          -- Signature help
          require("lsp_signature").on_attach({
            handler_opts = {
              border = "none",
            },
          })
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.completion.completionItem.resolveSupport = {
          properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
          },
        }

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

        -- Completion icons
        local icons = {
          Class = " ",
          Color = " ",
          Constant = " ",
          Constructor = " ",
          Enum = "了 ",
          EnumMember = " ",
          Field = " ",
          File = " ",
          Folder = " ",
          Function = " ",
          Interface = "ﰮ ",
          Keyword = " ",
          Method = "ƒ ",
          Module = " ",
          Property = " ",
          Snippet = "﬌ ",
          Struct = " ",
          Text = " ",
          Unit = " ",
          Value = " ",
          Variable = " ",
        }
        local kinds = vim.lsp.protocol.CompletionItemKind
        for i, kind in ipairs(kinds) do
          kinds[i] = icons[kind] or kind
        end

        local function sumneko_lua_paths()
          local path = {}
          table.insert(path, "lua/?.lua")
          table.insert(path, "lua/?/init.lua")
          local packer_config = require("packer").config
          local packer_start = string.format(
            "%s/%s",
            packer_config.package_root,
            packer_config.plugin_package
          )
          for _, plugin in ipairs({
            "popup.nvim",
            "plenary.nvim",
            "lazy.nvim",
            "nest.nvim",
          }) do
            local plugin_dir = string.format("%s/start/%s/lua", packer_start, plugin)
            table.insert(path, plugin_dir .. "/?.lua")
            table.insert(path, plugin_dir .. "/?/init.lua")
          end
          return path
        end
        local luadev = require("lua-dev").setup({
          lspconfig = {
            cmd = { "lua-language-server" },
            on_attach = on_attach,
            capabilities = capabilities,
            flags = {
              debounce_text_changes = 100,
            },
            settings = {
              Lua = {
                runtime = {
                  path = sumneko_lua_paths(),
                },
              },
            },
          },
        })
        require("lspconfig").sumneko_lua.setup(luadev)

        require("lspconfig")["bashls"].setup({
          on_attach = on_attach,
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
          on_attach = on_attach,
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
          on_attach = on_attach,
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
            on_attach = on_attach,
            capabilities = capabilities,
            flags = {
              debounce_text_changes = 100,
            },
          })
        end
      end,
    },

    {
      "jose-elias-alvarez/null-ls.nvim",
      commit = "eeb6c9907aae98fb2870091b15cfa6230e4d3f0e",
      config = function()
        require("null-ls").config({
          debounce = 100,
          sources = {
            require("null-ls").builtins.diagnostics.shellcheck,
            require("null-ls").builtins.formatting.shfmt,
            require("null-ls").builtins.formatting.stylua,
            require("null-ls").builtins.formatting.black,
          },
        })
        require("lspconfig")["null-ls"].setup({
          on_attach = function(client, bufnr)
            for lhs, rhs in pairs({
              ["<leader>a"] = "<Cmd>lua vim.lsp.buf.code_action()<CR>",
              ["<leader>d"] = '<Cmd>lua require("telescope.builtin").lsp_document_diagnostics()<CR>',
              ["<leader>D"] = '<Cmd>lua require("telescope.builtin").lsp_workspace_diagnostics()<CR>',
              ["]d"] = "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
              ["[d"] = "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>",
              ["<leader>F"] = "<Cmd>lua vim.lsp.buf.formatting()<CR>",
            }) do
              vim.api.nvim_buf_set_keymap(bufnr, "n", lhs, rhs, { noremap = true })
            end
            vim.api.nvim_buf_set_keymap(
              bufnr,
              "x",
              "<leader>F",
              ":lua vim.lsp.buf.range_formatting()<CR>",
              { noremap = true, silent = true }
            )
          end,
        })
      end,
    },

    { "folke/lua-dev.nvim", commit = "e9588503e68fa32ac08b83d9cb7e42ec31b8907d" },

    { "ray-x/lsp_signature.nvim", commit = "933ba2f059d965ee8db288f63869b8205ea223b8" },

    -- Git
    {
      "lewis6991/gitsigns.nvim",
      commit = "0d45fff0a28cebdc87604117c0fc46f3a64550f6",
      config = function()
        require("gitsigns").setup()
      end,
    },

    {
      "TimUntersberger/neogit",
      commit = "ee83d4fa8ac946e5e0064e65a5276e1ea030ae28",
      cmd = "Neogit",
      keys = "<leader>g",
      wants = "diffview.nvim",
      config = function()
        require("neogit").setup({
          disable_commit_confirmation = true,
          integrations = {
            diffview = true,
          },
        })
        vim.api.nvim_set_keymap("n", "<leader>g", "<Cmd>Neogit<CR>", { noremap = true })
      end,
    },

    {
      "sindrets/diffview.nvim",
      commit = "2411f5303192a9c8056ec174fb995773f90b52b8",
      cmd = "DiffviewOpen",
      config = function()
        require("diffview").setup({
          key_bindings = {
            view = {
              q = '<Cmd>lua require"diffview".close()<CR>',
            },
            file_panel = {
              q = '<Cmd>lua require"diffview".close()<CR>',
            },
          },
        })
      end,
    },

    -- Nix
    { "Freed-Wu/vim-nix", commit = "2fc254b90661f8190565b18874d0662bfcbec02c", ft = "nix" }, -- forked from LnL7/vim-nix

    -- Fish
    { "khaveesh/vim-fish-syntax", commit = "cf759d1ac42396ee2246a082eceb0debde04c445" },

    -- Jinja
    {
      "Glench/Vim-Jinja2-Syntax",
      commit = "2c17843b074b06a835f88587e1023ceff7e2c7d1",
      config = function()
        vim.g.jinja_syntax_html = 0
      end,
    },
    -- Ansible
    {
      "pearofducks/ansible-vim",
      commit = "804099202b72ffd4bf4ea4ce24d8d7bac8b9ae2d",
      config = function()
        vim.g.ansible_unindent_after_newline = 1
        vim.g.ansible_extra_keywords_highlight = 1
        vim.g.ansible_template_syntaxes = {
          ["*.sh.j2"] = "sh",
        }
      end,
    },
    -- SaltStack
    { "saltstack/salt-vim", commit = "6ca9e3500cc39dd417b411435d58a1b720b331cc" },
    -- MediaWiki
    {
      "chikamichi/mediawiki.vim",
      commit = "26e5737264354be41cb11d16d48132779795e168",
      config = function()
        vim.g.mediawiki_wikilang_to_vim_overrides = { sls = "sls" }
        vim.g.mediawiki_forced_wikilang = { "bash" }
      end,
    },
  },
})
