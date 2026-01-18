{
  snippets.lua = {
    jinja_filters.text = builtins.readFile ./jinja_filters.lua;
    jinja_statements.text = builtins.readFile ./jinja_statements.lua;
    jinja_stuff.text = builtins.readFile ./jinja_stuff.lua;
    jinja_tests.text = builtins.readFile ./jinja_tests.lua;
  };
}
