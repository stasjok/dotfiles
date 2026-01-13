{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      completion = {
        list.selection.preselect = false;
        menu.max_height = 20;
        documentation.auto_show = true;
      };
      cmdline.completion = {
        menu.auto_show = true;
        list.selection.preselect = false;
      };

      # Appearance
      appearance.nerd_font_variant = "normal";

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
      cmdline.keymap = {
        preset = "inherit";
        "<CR>" = false;
        "<M-d>" = false;
        "<M-u>" = false;
      };
    };
  };

  performance.combinePlugins.pathsToLink = [ "/target/release" ];
}
