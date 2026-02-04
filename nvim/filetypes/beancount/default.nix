{
  ftplugin.beancount = {
    opts = {
      shiftwidth = 2;
      commentstring = "; %s";
      comments = ":;";
      iskeyword = "@,48-57,_,192-255,:,-,.,#,^"; # '^' should be last
    };

    content = /* lua */ ''
      vim.keymap.set("n", "<LocalLeader>s", "<Cmd>Telescope beancount sections<CR>", { buffer = true })
    '';

    undo = "silent! nunmap <buffer> <LocalLeader>s";
  };

  # Telescope extension
  extraFiles."lua/telescope/_extensions/beancount.lua".text = builtins.readFile ./telescope.lua;
}
