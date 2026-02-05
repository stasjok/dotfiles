{
  imports = [
    ./blink-cmp.nix
    ./codecompanion
    ./mini
    ./smart_splits.nix
    ./surround.nix
    ./telescope.nix
  ];

  plugins = {
    # Restore a screen view when switching buffers
    fix-auto-scroll.enable = true;
  };
}
