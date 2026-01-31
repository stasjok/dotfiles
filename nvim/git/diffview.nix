{
  plugins.diffview = {
    enable = true;

    settings = {
      enhanced_diff_hl = true;

      keymaps = {
        view = [
          {
            mode = "n";
            key = "gq";
            action = "<Cmd>DiffviewClose<CR>";
          }
          {
            mode = "n";
            key = "c<CR>";
            action = "<Cmd>tab Git commit<CR>";
          }
          {
            mode = "n";
            key = "cv<CR>";
            action = "<Cmd>tab Git commit -v<CR>";
          }
          {
            mode = "n";
            key = "ca";
            action = "<Cmd>tab Git commit --amend<CR>";
          }
          {
            mode = "n";
            key = "cva";
            action = "<Cmd>tab Git commit -v --amend<CR>";
          }
          {
            mode = "n";
            key = "cvc";
            action = "<Cmd>tab Git commit -v <CR>";
          }
        ];
        file_panel = [
          {
            mode = "n";
            key = "gq";
            action = "<Cmd>DiffviewClose<CR>";
          }
          {
            mode = "n";
            key = "c<CR>";
            action = "<Cmd>tab Git commit<CR>";
          }
          {
            mode = "n";
            key = "cv<CR>";
            action = "<Cmd>tab Git commit -v<CR>";
          }
          {
            mode = "n";
            key = "ca";
            action = "<Cmd>tab Git commit --amend<CR>";
          }
          {
            mode = "n";
            key = "cc";
            action = "<Cmd>tab Git commit<CR>";
          }
          {
            mode = "n";
            key = "ce";
            action = "<Cmd>tab Git commit --amend --no-edit<CR>";
          }
          {
            mode = "n";
            key = "cva";
            action = "<Cmd>tab Git commit -v --amend<CR>";
          }
          {
            mode = "n";
            key = "cvc";
            action = "<Cmd>tab Git commit -v <CR>";
          }
        ];
        file_history_panel = [
          {
            mode = "n";
            key = "gq";
            action = "<Cmd>DiffviewClose<CR>";
          }
        ];
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<Leader>G";
      action = "<Cmd>DiffviewOpen<CR>";
    }
    {
      mode = "n";
      key = "<Leader>l";
      action = "<Cmd>DiffviewFileHistory<CR>";
    }
    {
      mode = "n";
      key = "<Leader>L";
      action = "<Cmd>DiffviewFileHistory %<CR>";
    }
  ];
}
