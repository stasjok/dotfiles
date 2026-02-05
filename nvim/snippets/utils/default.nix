{ lib, ... }:
{
  extraFiles =
    lib.genAttrs
      [
        "lua/snippets/expand_conditions.lua"
        "lua/snippets/functions.lua"
        "lua/snippets/jinja_utils.lua"
        "lua/snippets/nodes.lua"
        "lua/snippets/show_conditions.lua"
        "lua/treesitter/utils.lua"
        "queries/jinja2/ft_func.scm"
        "queries/yaml/ft_func.scm"
      ]
      (path: {
        text = builtins.readFile ./${path};
      });
}
