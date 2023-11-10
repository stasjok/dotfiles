{pkgs, ...}: {
  programs.k9s = {
    enable = true;
    skin = let
      catppuccinRepo = fetchTree {
        type = "github";
        owner = "catppuccin";
        repo = "k9s";
        rev = "516f44dd1a6680357cb30d96f7e656b653aa5059";
        narHash = "sha256-PtBJRBNbLkj7D2ko7ebpEjbfK9Ywjs7zbE+Y8FQVEfA=";
      };
      catppuccinMacchiatoSkin = builtins.fromJSON (builtins.readFile (
        pkgs.runCommandNoCC "k9s-catppuccin-macchiato-skin.json" {} ''
          ${pkgs.yq-go}/bin/yq -o json ${catppuccinRepo}/dist/macchiato.yml > $out
        ''
      ));
    in
      catppuccinMacchiatoSkin;
  };

  # Force 24-bit colors
  home.shellAliases.k9s = "TERM=xterm-256color COLORTERM=truecolor command k9s";
}
