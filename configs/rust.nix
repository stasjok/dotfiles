{
  programs.cargo = {
    enable = true;
  };

  # Add Cargo's install root directory to PATH
  home.sessionPath = ["$HOME/.cargo/bin"];
}
