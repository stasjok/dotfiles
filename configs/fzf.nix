{
  programs.fzf = {
    enable = true;

    # Tmux integration
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [ "-p80%,60%" ];
    };
  };
}
