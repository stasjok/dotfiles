{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  plugins.smart-splits = {
    enable = true;
    settings = {
      default_amount = 2;

      # Reduce log level
      log_level = "error";
    };
  };

  # Mappings
  keymaps =
    let
      move_keys = {
        "<M-h>" = "move_cursor_left";
        "<M-j>" = "move_cursor_down";
        "<M-k>" = "move_cursor_up";
        "<M-l>" = "move_cursor_right";
      };
      resize_keys = {
        "<M-H>" = "resize_left";
        "<M-J>" = "resize_down";
        "<M-K>" = "resize_up";
        "<M-L>" = "resize_right";
      };
    in
    lib.mapAttrsToList (key: action: {
      inherit key;
      mode = [
        "n"
        "v"
        "i"
        "t"
      ];
      action = mkRaw "require('smart-splits').${action}";
    }) resize_keys
    ++ builtins.concatLists (
      lib.mapAttrsToList (
        key: action:
        map
          (m: {
            inherit key;
            inherit (m) mode;
            action =
              if m ? pre_command then
                mkRaw ''
                  function()
                    ${m.pre_command}
                    require("smart-splits").${action}()
                  end
                ''
              else
                mkRaw "require('smart-splits').${action}";
          })
          [
            {
              mode = "n";
            }
            {
              mode = [
                "i"
                "t"
              ];
              pre_command = "vim.cmd.stopinsert()";
            }
            {
              mode = "v";
              pre_command = ''vim.api.nvim_feedkeys(vim.keycode('<C-\\><C-N>'), 'nx', false)'';
            }
          ]
      ) move_keys
    );
}
