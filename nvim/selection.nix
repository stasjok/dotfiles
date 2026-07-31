{
  # Tree-sitter incremental selection
  keymaps = [
    {
      mode = "n";
      key = "<CR>";
      # There is a problem in Nvim, that 'van' keeps last selection type (e.g. linewise)
      # It skips toggling visual mode if it's already 'v':
      # https://github.com/neovim/neovim/blob/66441e549d5c560f8b1d6d6b6e71244ce3569604/runtime/lua/vim/treesitter/_select.lua#L367-L370
      # As a workaround toggle normal visual mode first
      action = "vvvan";
      options.remap = true;
    }
    {
      mode = "x";
      key = "<CR>";
      action = "an";
      options.remap = true;
    }
    {
      mode = "x";
      key = "<C-J>"; # <C-CR>
      action = "in";
      options.remap = true;
    }
  ];

  ftplugin = {
    # Unmap <CR> mapping in |command-line-window|
    vim = {
      content = /* lua */ ''
        if vim.fn.win_gettype() == "command" then
          vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>", {})
        end
      '';
      undo = /* vim */ "silent! exe 'nunmap <buffer> <CR>'";
    };
    # Unmap <CR> mapping in |quickfix|
    qf.keymaps = [
      {
        mode = "n";
        key = "<CR>";
        action = "<CR>";
      }
    ];
  };
}
