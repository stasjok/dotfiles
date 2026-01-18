{
  imports = [
    ./salt.nix
  ];

  snippets.lua = {
    salt_filters.text = builtins.readFile ./salt_filters.lua;
    salt_jinja_stuff.text = builtins.readFile ./salt_jinja_stuff.lua;
    salt_statements.text = builtins.readFile ./salt_statements.lua;
    salt_tests.text = builtins.readFile ./salt_tests.lua;
  };
}
