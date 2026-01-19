{
  imports = [
    ./salt.nix
  ];

  snippets.filetype = {
    salt_filters = {
      lua.text = builtins.readFile ./salt_filters.lua;
    };
    salt_jinja_stuff = {
      lua.text = builtins.readFile ./salt_jinja_stuff.lua;
    };
    salt_statements = {
      lua.text = builtins.readFile ./salt_statements.lua;
    };
    salt_tests = {
      lua.text = builtins.readFile ./salt_tests.lua;
    };
  };
}
