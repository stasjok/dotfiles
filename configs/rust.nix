{config, ...}: {
  programs.cargo = {
    enable = true;

    settings = {
      install.root = "${config.home.homeDirectory}/.local";
    };
  };
}
