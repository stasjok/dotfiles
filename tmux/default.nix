{config, ...}: {
  programs.tmux = {
    enable = true;

    # Options
    terminal = "tmux-256color";
    prefix = "M-q";
    keyMode = "vi";
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

  # Source config file automatically when it's changed
  xdg.configFile."tmux/tmux.conf".onChange = ''
    if tmux has-session &>/dev/null; then
      tmux source-file ${config.xdg.configHome}/tmux/tmux.conf
    fi
  '';
}
