{ pkgs, lib, ... }:
{
  ftplugin.beancount = {
    opts = {
      shiftwidth = 2;
      commentstring = "; %s";
      comments = ":;";
      iskeyword = "@,48-57,_,192-255,:,-,.,#,^"; # '^' should be last
    };
    keymaps = [
      {
        mode = "n";
        key = "<LocalLeader>s";
        action = "<Cmd>Telescope beancount sections<CR>";
      }
      {
        mode = "n";
        key = "<LocalLeader>t";
        action = ''"_ciw<C-R>=strftime("%Y-%m-%d")<CR><Esc>'';
      }
      {
        mode = "n";
        key = "gR";
        action = lib.nixvim.mkRaw ''
          function()
            require("beancount.functions").print_references()
          end
        '';
        options.desc = "Print Beancount references";
      }
    ];
  };

  extraFiles = {
    # Beancount indent from nathangrigg/vim-beancount plugin
    "indent/beancount.vim" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/nathangrigg/vim-beancount/589a4f06f3b2fd7cd2356c2ef1dafadf6b7a97cf/indent/beancount.vim";
        hash = "sha256-p0mFlHdW/mWC3ABObTVGG8mNM3pO7OT4k9OG9Z5eUEQ=";
      };
    };

    # Functions
    "lua/beancount/functions.lua".text = builtins.readFile ./functions.lua;

    # Telescope extension
    "lua/telescope/_extensions/beancount.lua".text = builtins.readFile ./telescope.lua;
  };
}
