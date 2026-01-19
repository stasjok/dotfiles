{ lib, ... }:
{
  imports = [
    ./salt.nix
  ];

  snippets.lua = {
    salt_filters = lib.singleton {
      text = builtins.readFile ./salt_filters.lua;
    };
    salt_jinja_stuff = lib.singleton {
      text = builtins.readFile ./salt_jinja_stuff.lua;
    };
    salt_statements = lib.singleton {
      text = builtins.readFile ./salt_statements.lua;
    };
    salt_tests = lib.singleton {
      text = builtins.readFile ./salt_tests.lua;
    };
  };
}
