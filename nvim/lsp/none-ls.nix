{ pkgs, ... }:
{
  plugins.none-ls = {
    enable = true;

    sources = {
      formatting = {
        bean_format = {
          enable = true;
          # beancount v3 requires '-' to format stdin
          settings.args = [
            "--currency-column"
            "78"
            "-"
          ];
          # Already installed by home-manager, need to override by nix-develop
          package = null;
        };
        fish_indent = {
          enable = true;
          # Already installed by home-manager
          package = null;
        };
        mdformat.enable = true;
        packer = {
          enable = true;
          package = pkgs.packer;
        };
        stylua.enable = true;
      };
    };
  };
}
