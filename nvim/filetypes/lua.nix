{
  ftplugin.lua = {
    opts.shiftwidth = 2;

    keymaps = [
      {
        mode = [
          "n"
          "x"
        ];
        key = "<LocalLeader>s";
        action = ":source<CR>";
      }
    ];
  };
}
