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
    { 'nanotee/nvim-lua-guide', commit = 'bcbc72d9c0952d30d603e48603da034b0f095e61' },

    -- Solarized colorscheme
    { 'ishan9299/nvim-solarized-lua', commit = 'fa437ae65a6c1239525e4ec7f4cbf4671eaa55ba' },

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

    { 'windwp/nvim-autopairs', commit = 'b0bbe8d9089cbb045fd15d217ac5a5ec0f4f5066',
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
            :with_pair(function (opts)
              local pair = opts.line:sub(opts.col, opts.col + 1)
              return vim.tbl_contains({ '()', '[]', '{}' }, pair)
            end)
            :with_move(cond.none())
            :with_cr(cond.none()),
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

        function _G.OnEnterInsert()
          if vim.fn.pumvisible() ~= 0 then
            return vim.api.nvim_replace_termcodes('<CR>', true, false, true);
          else
            return require'nvim-autopairs'.autopairs_cr();
          end
        end
        vim.api.nvim_set_keymap('i' , '<CR>','v:lua.OnEnterInsert()', {expr = true , noremap = true});
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
