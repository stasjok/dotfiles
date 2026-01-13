{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      appearance.nerd_font_variant = "normal";
      completion = {
        list.selection.preselect = false;
        menu.max_height = 20;
        documentation.auto_show = true;
      };

      # Mappings
      keymap = {
        preset = "none";
        "<C-N>" = [
          "select_next"
          "fallback"
        ];
        "<C-P>" = [
          "select_prev"
          "fallback"
        ];
        "<Tab>" = [
          "select_next"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
          "fallback"
        ];
        "<CR>" = [
          "accept"
          "fallback"
        ];
        "<C-Y>" = [
          "accept"
          "show"
        ];
        "<C-E>" = [ "hide" ];
        "<M-d>" = [ "scroll_documentation_down" ];
        "<M-u>" = [ "scroll_documentation_up" ];
      };
    };
  };

  performance.combinePlugins.pathsToLink = [ "/target/release" ];
}
