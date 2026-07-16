{
  # Tree-sitter incremental selection
  keymaps = [
    {
      mode = "n";
      key = "<CR>";
      action = "van";
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

  # Unmap <CR> mapping in |command-line-window|
  ftplugin.vim = {
    content = /* lua */ ''
      if vim.fn.win_gettype() == "command" then
        vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>", {})
      end
    '';
    undo = /* vim */ "silent! exe 'nunmap <buffer> <CR>'";
  };
}
