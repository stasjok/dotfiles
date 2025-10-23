{ helpers, ... }:
{
  plugins.telescope = {
    enable = true;
    extensions.fzf-native.enable = true;

    settings = {
      defaults.mappings.i = {
        "<Esc>" = helpers.mkRaw "require('telescope.actions').close";
        "<C-C>" = false;
      };
      pickers.buffers.mappings = {
        i = {
          "<C-E>" = "delete_buffer";
        };
        n = {
          D = "delete_buffer";
        };
      };
    };
    # Avoid adding 'extraConfigVim'
    highlightTheme = null;

    # Mappings
    keymaps = {
      "<Leader>R" = "resume";
      "<Leader><Space>" = "buffers";
      "<Leader>f" = "find_files";
      "<Leader>s" = "live_grep";
      "<Leader>S" = "grep_string";
      "<Leader>;" = "commands";
      "<Leader>hh" = "help_tags";
    };
  };

  # No need to add bat
  dependencies.bat.enable = false;
}
