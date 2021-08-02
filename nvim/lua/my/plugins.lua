vim.api.nvim_command('packadd packer.nvim')

local packer = require 'packer';

packer.startup({
  -- Packer config
  config = {
    compile_path = require('packer.util').join_paths(vim.fn.stdpath 'data', 'site', 'plugin', 'packer_compiled.lua'),
    disable_commands = true
  },

  -- Plugins
  {
    -- Docs
    { 'nanotee/nvim-lua-guide', commit = 'bcbc72d9c0952d30d603e48603da034b0f095e61' },
    { 'nanotee/luv-vimdocs', commit = '915eb060b2bddec7dd256dd1028773243f078016' },

    -- Solarized colorscheme
    { 'ishan9299/nvim-solarized-lua', commit = 'fa437ae65a6c1239525e4ec7f4cbf4671eaa55ba' },

    -- Icons
    { 'kyazdani42/nvim-web-devicons', commit = 'da717e19678bd6ec33008cf92da05da1b8ceb87d' },

    -- Libraries
    { 'nvim-lua/popup.nvim', commit = '5e3bece7b4b4905f4ec89bee74c09cfd8172a16a' },
    { 'nvim-lua/plenary.nvim', commit = '8bae2c1fadc9ed5bfcfb5ecbd0c0c4d7d40cb974' },

    { 'aserowy/tmux.nvim', commit = '7d47e74b6fb3cd458cacdced36c2389510708ebe',
      config = function()
        require'tmux'.setup(
        { -- configuration
          resize = {
            resize_step_x = 2,
            resize_step_y = 2,
          }
        },
        { -- logging configuration
          file = "disabled",
        });
        for _, mode in ipairs({'n', 'v', 't'}) do
          vim.api.nvim_set_keymap(mode, '<M-h>', [[<Cmd>lua require'tmux'.move_left()<CR>]], {noremap = true});
          vim.api.nvim_set_keymap(mode, '<M-j>', [[<Cmd>lua require'tmux'.move_bottom()<CR>]], {noremap = true});
          vim.api.nvim_set_keymap(mode, '<M-k>', [[<Cmd>lua require'tmux'.move_top()<CR>]], {noremap = true});
          vim.api.nvim_set_keymap(mode, '<M-l>', [[<Cmd>lua require'tmux'.move_right()<CR>]], {noremap = true});
          vim.api.nvim_set_keymap(mode, '<M-H>', [[<Cmd>lua require'tmux'.resize_left()<CR>]], {noremap = true});
          vim.api.nvim_set_keymap(mode, '<M-J>', [[<Cmd>lua require'tmux'.resize_bottom()<CR>]], {noremap = true});
          vim.api.nvim_set_keymap(mode, '<M-K>', [[<Cmd>lua require'tmux'.resize_top()<CR>]], {noremap = true});
          vim.api.nvim_set_keymap(mode, '<M-L>', [[<Cmd>lua require'tmux'.resize_right()<CR>]], {noremap = true});
        end
        vim.api.nvim_set_keymap('i', '<M-h>', [[<Esc><Cmd>lua require'tmux'.move_left()<CR>]], {noremap = true});
        vim.api.nvim_set_keymap('i', '<M-j>', [[<Esc><Cmd>lua require'tmux'.move_bottom()<CR>]], {noremap = true});
        vim.api.nvim_set_keymap('i', '<M-k>', [[<Esc><Cmd>lua require'tmux'.move_top()<CR>]], {noremap = true});
        vim.api.nvim_set_keymap('i', '<M-l>', [[<Esc><Cmd>lua require'tmux'.move_right()<CR>]], {noremap = true});
        vim.api.nvim_set_keymap('i', '<M-H>', [[<Esc><Cmd>lua require'tmux'.resize_left()<CR>]], {noremap = true});
        vim.api.nvim_set_keymap('i', '<M-J>', [[<Esc><Cmd>lua require'tmux'.resize_bottom()<CR>]], {noremap = true});
        vim.api.nvim_set_keymap('i', '<M-K>', [[<Esc><Cmd>lua require'tmux'.resize_top()<CR>]], {noremap = true});
        vim.api.nvim_set_keymap('i', '<M-L>', [[<Esc><Cmd>lua require'tmux'.resize_right()<CR>]], {noremap = true});
      end
    },

    -- Comments
    {
      'winston0410/commented.nvim', commit = 'a7fed2e21cdef40ee91d79460fbb53085931d5df',
      config = function ()
        require('commented').setup {
          keybindings = {n = "gc", v = "gc", nl = "gcc"},
        }
      end
    },

    -- Tree-sitter
    {
      'nvim-treesitter/nvim-treesitter', commit = '29113e6892a46d4afff41417c0be7122a3b97ae6',
      run = ':TSUpdate', config = require'my.treesitter'.setup
    },

    -- Telescope
    {
      'nvim-telescope/telescope-fzf-native.nvim', commit = 'fe8c8d8cf7ff215ac83e1119cba87c016070b27e',
      run = 'mkdir -p build && gcc -O3 -Wall -Werror -fpic -shared src/fzf.c -o build/libfzf.so',
    },
    {
      'nvim-telescope/telescope.nvim', commit = 'c0f1999b0280bb042bba01c930dd94a4bfdee363',
      config = function()
        require'telescope'.setup{
          defaults = {
            mappings = {
              i = {
                ["<Esc>"] = require'telescope.actions'.close,
                ['<C-c>'] = false,
              },
            },
          },
        }
        require('telescope').load_extension('fzf')
        vim.api.nvim_set_keymap('n', '<leader> ', '<cmd>lua require"telescope.builtin".buffers()<CR>', {noremap = true})
        vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua require"telescope.builtin".find_files()<CR>', {noremap = true})
        vim.api.nvim_set_keymap('n', '<leader>s', '<cmd>lua require"telescope.builtin".live_grep()<CR>', {noremap = true})
      end
    },

    {
      'https://github.com/stasjok/surround.nvim', commit = '183d5107ab68190ddca53d29b398dcf83f3e5488',
      config = function ()
        require'surround'.setup({
          mappings_style = 'surround',
        })
      end
    },

    { 'windwp/nvim-autopairs', commit = '8b937f612e44e62c29db497b6af149719c30b9aa',
      config = function()
        require'nvim-autopairs'.setup({
          fast_wrap = {},
        })

        local npairs = require'nvim-autopairs'
        local Rule = require'nvim-autopairs.rule'
        local cond = require'nvim-autopairs.conds'

        -- Add spaces between parentheses
        -- https://github.com/windwp/nvim-autopairs/issues/78
        -- https://github.com/windwp/nvim-autopairs/wiki/Custom-rules/425d8b096433b1329808797ff78f3acf23bc438f
        -- But I've changed it a little
        npairs.add_rules {
          Rule(' ', ' ')
            :with_pair(function(opts)
              local pair = opts.line:sub(opts.col - 1, opts.col)
              return vim.tbl_contains({ '()', '{}', '[]' }, pair)
            end)
            :with_move(cond.none())
            :with_cr(cond.none())
            :with_del(function(opts)
              local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- plus one to match plugin behavior
              local context = opts.line:sub(col - 2, col + 1)
              return vim.tbl_contains({ '(  )', '{  }', '[  ]' }, context)
            end),
          Rule('', ' )')
            :with_pair(cond.none())
            :with_move(function(opts) return opts.char == ')' end)
            :with_cr(cond.none())
            :with_del(cond.none())
            :use_key(')'),
          Rule('', ' }')
            :with_pair(cond.none())
            :with_move(function(opts) return opts.char == '}' end)
            :with_cr(cond.none())
            :with_del(cond.none())
            :use_key('}'),
          Rule('', ' ]')
            :with_pair(cond.none())
            :with_move(function(opts) return opts.char == ']' end)
            :with_cr(cond.none())
            :with_del(cond.none())
            :use_key(']'),
        }
      end
    },

    -- Snippets
    {
      'L3MON4D3/LuaSnip', commit = '631a1551c9e0d983e9545d37c79fb024f4680a83',
      config = function()
        require'luasnip.config'.setup({})

        _G.luasnip_choose = function(num)
          if require("luasnip").choice_active() then
            return vim.api.nvim_replace_termcodes('<Cmd>lua require"luasnip".change_choice('..num..')<CR>', true, false, true)
          else
            return vim.api.nvim_replace_termcodes('<Ignore>', true, false, true)
          end
        end

        vim.api.nvim_set_keymap('i', '<C-h>', '<Cmd>lua require"luasnip".expand()<CR>', {noremap = true})
        for _, m in ipairs({'i', 's'}) do
          vim.api.nvim_set_keymap(m, '<C-j>', '<Cmd>lua require"luasnip".jump(1)<CR>', {noremap = true})
          vim.api.nvim_set_keymap(m, '<C-k>', '<Cmd>lua require"luasnip".jump(-1)<CR>', {noremap = true})
          vim.api.nvim_set_keymap(m, '<C-l>', 'v:lua.luasnip_choose(1)', {expr = true, noremap = true})
        end
        vim.api.nvim_set_keymap('s', '<BS>', '<C-o>c', {noremap = true})
        vim.api.nvim_set_keymap('s', '<Del>', '<C-o>c', {noremap = true})

        vim.api.nvim_command('runtime snippets/snippets.lua')
      end
    },

    -- Auto completion
    {
      'hrsh7th/nvim-compe', commit = '73529ce61611c9ee3821e18ecc929c422416c462',
      config = function()
        require'compe'.setup{
          source = {
            nvim_lsp = true;
            luasnip = true,
            buffer = true,
            path = true,
          }
        }
        vim.opt.completeopt = {'menuone', 'noselect'}
        require'nvim-autopairs.completion.compe'.setup()

        _G.complete_show_confirm = function(key)
          if vim.fn.pumvisible() == 1 then
            return vim.fn['compe#confirm']()
          else
            return vim.fn['compe#complete']()
          end
        end

        vim.api.nvim_set_keymap('i', '<C-y>', 'v:lua.complete_show_confirm()',
                                {expr = true, noremap = true})
        -- without extra <C-e> keys like <C-n>/<C-p> doesn't work, don't know why
        vim.api.nvim_set_keymap('i', '<C-e>', '<Cmd>lua require"compe"._close()<CR><C-e>', {noremap = true})
        vim.api.nvim_set_keymap('i', '<M-d>', 'compe#scroll({ "delta": +8 })',
                                {expr = true, noremap = true})
        vim.api.nvim_set_keymap('i', '<M-u>', 'compe#scroll({ "delta": -8 })',
                                {expr = true, noremap = true})
        _G.tab_complete = function()
          if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes('<C-n>', true, false, true)
          else
            return vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
          end
        end
        _G.s_tab_complete = function()
          if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes('<C-p>', true, false, true)
          else
            return vim.api.nvim_replace_termcodes('<C-d>', true, false, true)
          end
        end
        vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', {expr = true, noremap = true})
        vim.api.nvim_set_keymap('i', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true, noremap = true})
      end,
    },

    {
      'neovim/nvim-lspconfig', commit = '8b5f017fdf4ac485cfffbf4c93b7f3ce8de792f7',
      config = function()
        local on_attach = function(client, bufnr)
          for lhs, rhs in pairs {
            gd = '<Cmd>lua vim.lsp.buf.definition()<CR>',
            gD = '<Cmd>lua vim.lsp.buf.declaration()<CR>',
            ['<leader>D'] = '<Cmd>lua vim.lsp.buf.type_definition()<CR>',
            ['<leader>i'] = '<Cmd>lua vim.lsp.buf.implementation()<CR>',
            gr = '<Cmd>lua vim.lsp.buf.references()<CR>',
            ['<leader>r'] = '<Cmd>lua vim.lsp.buf.rename()<CR>',
            K = '<Cmd>lua vim.lsp.buf.hover()<CR>',
            ['<leader>a'] = '<Cmd>lua vim.lsp.buf.code_action()<CR>',
            ['<leader>d'] = '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
            [']d'] = '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>',
            ['[d'] = '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',
            ['<leader>F'] = '<Cmd>lua vim.lsp.buf.formatting()<CR>',
          } do
            vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, {noremap = true})
          end
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.completion.completionItem.resolveSupport = {
          properties = {
            'documentation',
            'detail',
            'additionalTextEdits',
          }
        }

        -- Diagnostics settings
        vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = false,
          update_in_insert = true,
        })

        -- Diagnostics icons
        local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }
        for type, icon in pairs(signs) do
          local hl = "LspDiagnosticsSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Show diagnostics automatically
        vim.cmd [[
          augroup ShowDiagnostics
          autocmd!
          autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})
          augroup END
        ]]

        -- Lua language server
        local runtime_path = vim.split(package.path, ';')
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")

        require'lspconfig'.sumneko_lua.setup {
          cmd = {'lua-language-server'},
          settings = {
            Lua = {
              runtime = {
                version = 'LuaJIT',
                path = runtime_path,
              },
              completion = {
                callSnippet = 'Replace'
              },
              diagnostics = {
                globals = {'vim'},
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
              },
              telemetry = {
                enable = false,
              },
            },
          },
          on_attach = on_attach,
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 100,
          },
        }
        for _, lsp_server in ipairs {} do
          require'lspconfig'[lsp_server].setup {
            on_attach = on_attach,
            capabilities = capabilities,
            flags = {
              debounce_text_changes = 100,
            },
          }
        end
      end
    },

    -- Git
    {
      'lewis6991/gitsigns.nvim', commit = '0d45fff0a28cebdc87604117c0fc46f3a64550f6',
      config = function ()
        require'gitsigns'.setup()
      end
    },

    {
      'TimUntersberger/neogit', commit = 'ee83d4fa8ac946e5e0064e65a5276e1ea030ae28',
      cmd = 'Neogit',
      keys = '<leader>g',
      wants = 'diffview.nvim',
      config = function ()
        require'neogit'.setup {
          disable_commit_confirmation = true,
          integrations = {
            diffview = true,
          },
        }
        vim.api.nvim_set_keymap('n', '<leader>g', '<Cmd>Neogit<CR>', {noremap = true})
      end
    },

    {
      'sindrets/diffview.nvim', commit = '2411f5303192a9c8056ec174fb995773f90b52b8',
      cmd = 'DiffviewOpen',
      config = function ()
        require'diffview'.setup {
          key_bindings = {
            view = {
              q = '<Cmd>lua require"diffview".close()<CR>'
            },
            file_panel = {
              q = '<Cmd>lua require"diffview".close()<CR>'
            },
          },
        }
      end
    },

    -- Nix
    { 'Freed-Wu/vim-nix', commit = '2fc254b90661f8190565b18874d0662bfcbec02c', ft = 'nix' }, -- forked from LnL7/vim-nix

    -- Fish
    { 'khaveesh/vim-fish-syntax', commit = 'cf759d1ac42396ee2246a082eceb0debde04c445' },

    -- Jinja
    { 'Glench/Vim-Jinja2-Syntax', commit = '2c17843b074b06a835f88587e1023ceff7e2c7d1',
      config = function()
        vim.g.jinja_syntax_html = 0
      end
    },
    -- Ansible
    { 'pearofducks/ansible-vim', commit = '804099202b72ffd4bf4ea4ce24d8d7bac8b9ae2d',
      config = function()
        vim.g.ansible_unindent_after_newline = 1;
        vim.g.ansible_extra_keywords_highlight = 1;
        vim.g.ansible_template_syntaxes = {
          ['*.sh.j2'] = 'sh',
        }
      end
    },
    -- SaltStack
    { 'saltstack/salt-vim', commit = '6ca9e3500cc39dd417b411435d58a1b720b331cc' },
    -- MediaWiki
    { 'chikamichi/mediawiki.vim', commit = '26e5737264354be41cb11d16d48132779795e168',
      config = function()
        vim.g.mediawiki_wikilang_to_vim_overrides = { sls = 'sls' };
        vim.g.mediawiki_forced_wikilang = { 'bash' };
      end
    },
  }
});

packer.sync();
-- Allow lazy-loaded plugins to load again
for _, var in ipairs {
  'neovim_loaded', -- neogit
  'diffview_nvim_loaded'
} do
  vim.api.nvim_del_var(var)
end
vim.api.nvim_command('packloadall!');
vim.api.nvim_command('runtime packer_compiled.lua');
