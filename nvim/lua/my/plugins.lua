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

    -- Tree-sitter
    { 'nvim-treesitter/nvim-treesitter', commit = '29113e6892a46d4afff41417c0be7122a3b97ae6',
    run = ':TSUpdate', config = require'my.treesitter'.setup },

    -- Nix
    { 'Freed-Wu/vim-nix', commit = '2fc254b90661f8190565b18874d0662bfcbec02c' }, -- forked from LnL7/vim-nix
  }
});

packer.sync();
