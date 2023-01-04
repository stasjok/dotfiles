{
  config,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;

    # Options managed by home-manager
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

    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour macchiato
        '';
      }
    ];

    # My config
    extraConfig = builtins.readFile ./tmux.conf;
  };

  # Source config file automatically when it's changed
  xdg.configFile."tmux/tmux.conf".onChange = let
    tmux = "${config.programs.tmux.package}/bin/tmux";
  in ''
    if ${tmux} has-session &>/dev/null; then
      ${tmux} source-file ${config.xdg.configHome}/tmux/tmux.conf
    fi
  '';
}
