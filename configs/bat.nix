{
  lib,
  pkgs,
  ...
}:
with builtins;
with lib; let
  # Catppuccin theme
  catppuccinThemeSrc = fetchTree {
    type = "github";
    owner = "catppuccin";
    repo = "bat";
    rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
    narHash = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
  };
  catppuccinThemeNames = pipe (readDir catppuccinThemeSrc) [
    attrNames
    (filter (name: hasSuffix ".tmTheme" name))
    (map (name: removeSuffix ".tmTheme" name))
  ];
  catppuccinThemes = genAttrs catppuccinThemeNames (name: readFile "${catppuccinThemeSrc}/${name}.tmTheme");
in {
  programs.bat = {
    enable = true;

    config = {
      theme = "Catppuccin-macchiato";
    };

    themes = catppuccinThemes;
  };

  # Update bat cache automatically
  xdg.configFile = let
    overridedAttrs = {onChange = "${pkgs.bat}/bin/bat cache --build >/dev/null";};
  in
    pipe catppuccinThemeNames [
      (map (name: nameValuePair "bat/themes/${name}.tmTheme" overridedAttrs))
      listToAttrs
    ];
}
