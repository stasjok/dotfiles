{ lib, ... }:
{
  snippets.lua = {
    jinja_filters = lib.singleton {
      text = builtins.readFile ./jinja_filters.lua;
    };
    jinja_statements = lib.singleton {
      text = builtins.readFile ./jinja_statements.lua;
    };
    jinja_stuff = lib.singleton {
      text = builtins.readFile ./jinja_stuff.lua;
    };
    jinja_tests = lib.singleton {
      text = builtins.readFile ./jinja_tests.lua;
    };
  };
}
