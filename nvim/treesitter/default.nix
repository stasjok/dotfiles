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
          return ft == "yaml.ansible" or ft:find("%.jinja2?$")
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
