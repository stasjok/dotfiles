{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.cargo;
  tomlFormat = pkgs.formats.toml { };
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  options.programs.cargo = {
    enable = mkEnableOption "Rust package manager";

    package = mkOption {
      type = types.package;
      default = pkgs.cargo;
      description = "The package to use for cargo";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "Cargo’s configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.cargo ];

    home.file.".cargo/config.toml" = mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "cargo-config" cfg.settings;
    };
  };
}
