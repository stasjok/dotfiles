{
  programs.k9s = {
    enable = true;
  };

  # Force 24-bit colors
  home.shellAliases.k9s = "TERM=xterm-256color COLORTERM=truecolor command k9s";
}
