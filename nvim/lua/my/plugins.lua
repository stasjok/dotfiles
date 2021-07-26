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
        vim.api.nvim_set_keymap('n', '<leader>g', '<cmd>lua require"telescope.builtin".live_grep()<CR>', {noremap = true})
      end
    },

    { 'windwp/nvim-autopairs', commit = 'e3e105b11a3b34e93bdcee0c895801cf3ed2a835',
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

    -- Auto completion
    {
      'hrsh7th/nvim-compe', commit = '73529ce61611c9ee3821e18ecc929c422416c462',
      config = function()
        require'compe'.setup{
          source = {
            buffer = true,
            path = true,
            nvim_lua = true,
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
        vim.api.nvim_set_keymap('i', '<C-n>', 'compe#complete()',
                                {expr = true, noremap = true})
        vim.api.nvim_set_keymap('i', '<C-e>', 'compe#close("<C-e>")',
                                {expr = true, noremap = true})
        vim.api.nvim_set_keymap('i', '<C-f>', 'compe#scroll({ "delta": +8 })',
                                {expr = true, noremap = true})
        vim.api.nvim_set_keymap('i', '<C-b>', 'compe#scroll({ "delta": -8 })',
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
      ft = 'mediawiki',
      config = function()
        vim.g.mediawiki_wikilang_to_vim_overrides = { sls = 'sls' };
        vim.g.mediawiki_forced_wikilang = { 'bash' };
      end
    },
  }
});

packer.sync();
vim.api.nvim_command('packloadall!');
vim.api.nvim_command('runtime packer_compiled.lua');
