{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      keymap.preset = "enter";
      appearance.nerd_font_variant = "normal";
      completion.documentation.auto_show = true;
    };
  };

  performance.combinePlugins.pathsToLink = [ "/target/release" ];
}
