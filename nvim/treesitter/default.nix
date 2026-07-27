{
  lib,
  ...
}:
{
  plugins.treesitter = {
    enable = true;

    highlight = {
      enable = true;
      disable = lib.nixvim.mkRaw ''
        function(_, _, ft)
          return ft:find("%.jinja2?$") or vim.list_contains({
            -- Disable for filetypes for which builtin ftplugin already enables tree-sitter highlight
            "lua",
            "help",
            "query",
            "markdown",
            -- Enabled in filetypes/ansible
            "ansible",
          }, ft)
        end
      '';
    };

    indent = {
      enable = true;
      disable = [
        "yaml"
        "fish"
      ];
    };
  };
}
