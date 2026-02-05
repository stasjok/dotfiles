{ lib, ... }:
let
  group = "AutoCmds";
in
{
  autoGroups.${group} = { };
  autoCmd = [
    # Don't show trailing spaces during insert mode
    {
      inherit group;
      event = "InsertEnter";
      desc = "Set 'listchars' to not show trailing spaces";
      command = "setlocal listchars-=trail:⋅";
    }
    {
      inherit group;
      event = "InsertLeave";
      desc = "Set 'listchars' to show trailing spaces";
      command = "setlocal listchars+=trail:⋅";
    }

    # Highlight the yanked text
    {
      inherit group;
      event = "TextYankPost";
      desc = "Highlight the yanked text";
      callback = lib.nixvim.mkRaw ''
        function()
          vim.hl.on_yank()
        end
      '';
    }
  ];
}
