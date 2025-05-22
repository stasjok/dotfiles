{
  config,
  lib,
  pkgs,
  ...
}:
let
  catppuccinCfg = config.catppuccin;
  cfg = catppuccinCfg.gh-dash;
  ghDashCfg = config.programs.gh-dash;
  theme = "${catppuccinCfg.sources.gh-dash}/themes/${cfg.flavor}/catppuccin-${cfg.flavor}-${cfg.accent}.yml";
in
{
  # A workaround to avoid IFD
  config = lib.mkMerge [
    { catppuccin.gh-dash.enable = false; }

    (lib.mkIf (catppuccinCfg.enable && ghDashCfg.enable) {
      # Merge catppuccin theme with gh-dash settings using yq
      xdg.configFile."gh-dash/config.yml".source = lib.mkForce (
        pkgs.runCommand "gh-dash-config.yml"
          {
            nativeBuildInputs = [ pkgs.yq-go ];
            settings = builtins.toJSON ghDashCfg.settings;
            passAsFile = [ "settings" ];
          }
          ''
            yq --output-format yaml --prettyPrint 'load("${theme}") * .' <$settingsPath >$out
          ''
      );
    })
  ];
}
