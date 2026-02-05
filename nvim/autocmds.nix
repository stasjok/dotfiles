let
  group = "AutoCmds";
in
{
  # Don't show trailing spaces during insert mode
  autoGroups.${group} = { };
  autoCmd = [
    {
      event = "InsertEnter";
      desc = "Set 'listchars' to not show trailing spaces";
      command = "setlocal listchars-=trail:⋅";
      inherit group;
    }
    {
      event = "InsertLeave";
      desc = "Set 'listchars' to show trailing spaces";
      command = "setlocal listchars+=trail:⋅";
      inherit group;
    }
  ];
}
