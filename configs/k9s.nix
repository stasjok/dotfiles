{pkgs, ...}: {
  programs.k9s = {
    enable = true;

    settings.k9s.ui.skin = "catppuccin-macchiato";

    skins.catppuccin-macchiato = builtins.fromJSON (builtins.readFile (
      pkgs.runCommandNoCC "k9s-catppuccin-macchiato-skin.json" {} ''
        ${pkgs.yq-go}/bin/yq -o json ${pkgs.catppuccin}/k9s/catppuccin-macchiato.yaml > $out
      ''
    ));
  };

  # Force 24-bit colors
  home.shellAliases.k9s = "TERM=xterm-256color COLORTERM=truecolor command k9s";
}
