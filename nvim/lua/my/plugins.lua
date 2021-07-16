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

    -- Tree-sitter
    {
      'nvim-treesitter/nvim-treesitter', commit = '29113e6892a46d4afff41417c0be7122a3b97ae6',
      run = ':TSUpdate', config = require'my.treesitter'.setup,
      ft = {
        'nix',
      },
      cmd = {
        'TSInstall',
        'TSInstallFromGrammar',
        'TSInstallInfo',
        'TSUpdate',
        'TSUninstall',
        'TSConfigInfo',
        'TSBufEnable',
        'TSBufDisable',
        'TSBufToggle',
        'TSEnableAll',
        'TSDisableAll',
        'TSToggleAll',
        'TSModuleInfo',
        'TSEditQuery',
        'TSEditQueryUserAfter'
      },
      module = 'nvim-treesitter.ts_utils'
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
    }
  }
});

packer.sync();
vim.api.nvim_command('packloadall!');
vim.api.nvim_command('runtime packer_compiled.lua');
