{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      keymap.preset = "enter";
      appearance.nerd_font_variant = "normal";
      completion = {
        menu.max_height = 20;
        documentation.auto_show = true;
      };
    };
  };

  performance.combinePlugins.pathsToLink = [ "/target/release" ];
}
