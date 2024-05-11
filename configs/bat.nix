{pkgs, ...}: {
  programs.bat = {
    enable = true;

    config = {
      theme = "Catppuccin Macchiato";
    };

    themes."Catppuccin Macchiato" = {
      src = pkgs.catppuccin;
      file = "bat/Catppuccin Macchiato.tmTheme";
    };
  };
}
