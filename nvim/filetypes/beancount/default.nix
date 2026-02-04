{ pkgs, ... }:
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

  extraFiles = {
    # Beancount indent from nathangrigg/vim-beancount plugin
    "indent/beancount.vim" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/nathangrigg/vim-beancount/589a4f06f3b2fd7cd2356c2ef1dafadf6b7a97cf/indent/beancount.vim";
        hash = "sha256-p0mFlHdW/mWC3ABObTVGG8mNM3pO7OT4k9OG9Z5eUEQ=";
      };
    };
  };

  # Telescope extension
  extraFiles."lua/telescope/_extensions/beancount.lua".text = builtins.readFile ./telescope.lua;
}
