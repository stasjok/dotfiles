return {
  setup = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'nix',
      },
      highlight = { enable = true },
    }
  end,
}
