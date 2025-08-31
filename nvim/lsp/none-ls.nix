{ pkgs, ... }:
{
  plugins.none-ls = {
    enable = true;

    sources = {
      formatting = {
        bean_format = {
          enable = true;
          # beancount v3 requires '-' to format stdin
          settings.args = [ "-" ];
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

      diagnostics = {
        markdownlint.enable = true;
      };
    };
  };
}
