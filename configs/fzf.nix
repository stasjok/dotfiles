{
  programs.fzf = {
    enable = true;
    # It's already configured from ~/.nix-profile/share/fish/vendor_conf.d
    enableFishIntegration = false;

    # Tmux integration
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = ["-p"];
    };
  };
}
