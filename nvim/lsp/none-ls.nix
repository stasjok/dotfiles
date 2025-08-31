{ pkgs, ... }:
{
  plugins.none-ls = {
    enable = true;

    sources = {
      formatting = {
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
