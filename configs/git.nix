{
  programs.git = {
    enable = true;

    userName = "Stanislav Asunkin";
    userEmail = "1353637+stasjok@users.noreply.github.com";

    aliases = {
      tree = "log --oneline --decorate --all --graph";
    };

    ignores = [
      "*.swp"
      "*.swo"
      "*.swn"
    ];

    extraConfig = {
      # Cache credentials
      credential.helper = "cache --timeout 3600";

      # Allow only fast-forward merges when pulling
      pull.ff = "only";

      # A style for conflicted hunks
      merge.conflictStyle = "zdiff3";

      # Git status
      status.showUntrackedFiles = "all";

      # Git diff
      diff = {
        colorMoved = "default";
        colorMovedWS = "allow-indentation-change";
      };
    };

    # Delta
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        true-color = "always";

        # Catppuccin Macchiato theme
        syntax-theme = "Catppuccin-macchiato";
        map-styles = "bold purple => syntax #302d40, bold blue => syntax #3c3345, bold cyan => syntax #2c323f, bold yellow => syntax #343C45";
        plus-style = "syntax #3b474a";
        plus-emph-style = "syntax #53675b";
        plus-empty-line-marker-style = "plus-style";
        minus-style = "syntax #48384b";
        minus-emph-style = "syntax #6c4a5b";
        minus-empty-line-marker-style = "minus-style";
        whitespace-error-style = "reverse red";
        line-numbers-minus-style = "#ed8796";
        line-numbers-plus-style = "#a6da95";
        line-numbers-zero-style = "#494d64";
        line-numbers-left-format = "{nm:^1}⋮";
        line-numbers-right-format = "{np:^1}│";
        blame-format = "{author:<18} ({commit:>8}) {timestamp:>15}";
        blame-palette = "#181926 #1e2030 #24273a #363a4f";
        blame-separator-style = "blue";
      };
    };
  };
}
