{ config, ... }:
{
  programs.tmux = {
    enable = true;

    # Options managed by home-manager
    terminal = "tmux-256color";
    prefix = "M-q";
    keyMode = "vi";
    mouse = true;
    historyLimit = 50000;
    escapeTime = 5;
    baseIndex = 1;
    clock24 = true;

    # Disable tmux-sensible plugin
    sensibleOnTop = false;

    # Store tmux socket in /run/user/<UID>
    secureSocket = true;

    # My config
    extraConfig = builtins.readFile ./tmux.conf;
  };

  # Catppuccin theme settings
  catppuccin.tmux.extraConfig = ''
    # Use basename of the current directory as window name
    set-option -g @catppuccin_window_text " #{b:pane_current_path}"
    set-option -g @catppuccin_window_current_text " #{b:pane_current_path}"
  '';

  # Source config file automatically when it's changed
  xdg.configFile."tmux/tmux.conf".onChange =
    let
      tmux = "${config.programs.tmux.package}/bin/tmux";
    in
    ''
      if ${tmux} has-session &>/dev/null; then
        ${tmux} source-file ${config.xdg.configHome}/tmux/tmux.conf
      fi
    '';
}
