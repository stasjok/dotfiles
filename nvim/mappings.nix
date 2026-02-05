{ lib, ... }:
{
  # Set <Leader> to <Space> and <LocalLeader> to `\`
  globals = {
    mapleader = " ";
    maplocalleader = "\\";
  };

  keymaps = [
    # Leader shouldn't work by itself
    {
      mode = [
        "n"
        "x"
      ];
      key = "<Leader>";
      action = "<Nop>";
    }

    # Emacs-like mappings
    {
      mode = "!";
      key = "<C-B>";
      action = "<Left>";
    }
    {
      mode = "!";
      key = "<C-F>";
      action = "<Right>";
    }
    {
      mode = "!";
      key = "<M-b>";
      action = "<C-Left>";
    }
    {
      mode = "!";
      key = "<M-f>";
      action = "<C-Right>";
    }
    {
      mode = "i";
      key = "<C-N>";
      action = "<Down>";
    }
    {
      mode = "i";
      key = "<C-P>";
      action = "<Up>";
    }
    {
      mode = "c";
      key = "<C-A>";
      action = "<C-B>";
    }
    {
      mode = "!";
      key = "<M-BS>";
      action = "<C-W>";
    }
    {
      mode = "c";
      key = "<M-d>";
      action = "<C-F>dw<C-C>";
    }

    # Scrolling in insert mode (including completion popup)
    {
      mode = "i";
      key = "<M-F>";
      action = "<PageDown>";
    }
    {
      mode = "i";
      key = "<M-B>";
      action = "<PageUp>";
    }

    # Shortcuts
    {
      mode = "n";
      key = "<Leader><CR>";
      action = "<Cmd>buffer #<CR>";
    }
    {
      mode = "n";
      key = "<Leader>e";
      action = "<Cmd>edit<CR>";
    }
    {
      mode = "n";
      key = "<Leader>E";
      action = "<Cmd>edit!<CR>";
    }
    {
      mode = "n";
      key = "<Leader>c";
      action = "<Cmd>close<CR>";
    }
    {
      mode = "n";
      key = "<Leader>C";
      action = "<Cmd>buffer #<CR><Cmd>bdelete #<CR>";
    }
    {
      mode = "n";
      key = "<Leader>w";
      action = "<Cmd>write<CR>";
    }
    {
      mode = "n";
      key = "<Leader>W";
      action = "<Cmd>wall<CR>";
    }
    {
      mode = "n";
      key = "<Leader>q";
      action = "<Cmd>quit<CR>";
    }
    {
      mode = "n";
      key = "<Leader>Q";
      action = "<Cmd>quitall<CR>";
    }
    {
      mode = "n";
      key = "<Leader>z";
      action = "<Cmd>xit<CR>";
    }
    {
      mode = "n";
      key = "<Leader>Z";
      action = "<Cmd>xall<CR>";
    }

    # Decrease indent
    {
      mode = "i";
      key = "<S-Tab>";
      action = "<C-D>";
    }

    # Append semicolon to the end of line
    {
      mode = "i";
      key = "<C-_>";
      action = "<End>;";
    }

    # Move lines
    {
      mode = "n";
      key = "<M-d>";
      action = "<Cmd>move .+1<CR>";
    }
    {
      mode = "n";
      key = "<M-u>";
      action = "<Cmd>move .-2<CR>";
    }
    {
      mode = "v";
      key = "<M-d>";
      action = ":move '>+1<CR>gv";
      options.silent = true;
    }
    {
      mode = "v";
      key = "<M-u>";
      action = ":move '<-2<CR>gv";
      options.silent = true;
    }

    # Window management
    {
      mode = "n";
      key = "<Leader>x";
      action = "<C-W>v";
    }
    {
      mode = "n";
      key = "<Leader>v";
      action = "<C-W>s";
    }
    {
      mode = "n";
      key = "<Leader>|";
      action = "<C-W>|";
    }
    {
      mode = "n";
      key = "<Leader>_";
      action = "<C-W>_";
    }
    {
      mode = "n";
      key = "<Leader>=";
      action = "<C-W>=";
    }

    # Mouse mappings
    # automatic yanking after mouse selection
    {
      mode = "v";
      key = "<LeftRelease>";
      action = ''<LeftRelease>"*y'';
    }
    # by default MiddleMouse yanks to unnamed buffer, but pastes from * (why?); change yanking also to *
    {
      mode = "v";
      key = "<MiddleMouse>";
      action = ''"*y<MiddleMouse>'';
    }
    # by default MiddleMouse pastes at the position of the cursor in normal mode, but not in insert mode; fix it
    {
      mode = "i";
      key = "<MiddleMouse>";
      action = "<LeftMouse><MiddleMouse>";
    }
    # increase mouse scroll speed
    {
      mode = [
        ""
        "i"
        "t"
      ];
      key = "<ScrollWheelUp>";
      action = "<ScrollWheelUp><ScrollWheelUp>";
    }
    {
      mode = [
        ""
        "i"
        "t"
      ];
      key = "<ScrollWheelDown>";
      action = "<ScrollWheelDown><ScrollWheelDown>";
    }

    # Make j/k movement a jump if count > 5
    {
      mode = "n";
      key = "j";
      action = ''(v:count1 > 5 ? "m'"..v:count : "") .. "j"'';
      options.expr = true;
    }
    {
      mode = "n";
      key = "k";
      action = ''(v:count1 > 5 ? "m'"..v:count : "") .. "k"'';
      options.expr = true;
    }

    # Clear search highlighting by pressing Esc
    {
      mode = "n";
      key = "<Esc>";
      action = "<Cmd>nohlsearch<CR>";
    }

    # Jump to tag forward (inverse of Ctrl-t)
    {
      mode = "n";
      key = "<C-P>";
      action = "<Cmd>:tag<CR>";
    }

    # Enables russian-jcukenwin keymap if disabled, then toggles iminsert.
    {
      mode = [
        "!"
        "s"
      ];
      key = "<M-i>";
      action = lib.nixvim.mkRaw ''
        function()
          if #vim.opt_local.keymap:get() == 0 then
            vim.opt_local.keymap = "russian-jcukenwin"
          end
          vim.api.nvim_feedkeys(vim.keycode("<C-^>"), "n", false)
        end
      '';
    }
  ];
}
