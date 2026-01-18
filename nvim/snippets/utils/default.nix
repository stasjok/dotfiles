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
      ]
      (path: {
        text = builtins.readFile ./${path};
      });
}
