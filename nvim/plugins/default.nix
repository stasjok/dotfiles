{
  imports = [
    ./blink-cmp.nix
    ./codecompanion
    ./luasnip
    ./mini.nix
    ./smart_splits.nix
    ./telescope.nix
  ];

  plugins = {
    # Restore a screen view when switching buffers
    fix-auto-scroll.enable = true;
  };
}
