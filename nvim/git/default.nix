{
  # vim-fugitive
  plugins.fugitive.enable = true;
  keymaps = [
    {
      mode = "n";
      key = "<Leader>g";
      action = "<Cmd>tab Git<CR>";
    }
  ];

  imports = [
    ./diffview.nix
    ./gitsigns.nix
  ];
}
