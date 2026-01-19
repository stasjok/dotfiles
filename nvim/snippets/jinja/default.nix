{
  snippets.filetype = {
    jinja_filters = {
      lua.text = builtins.readFile ./jinja_filters.lua;
    };
    jinja_statements = {
      lua.text = builtins.readFile ./jinja_statements.lua;
    };
    jinja_stuff = {
      lua.text = builtins.readFile ./jinja_stuff.lua;
    };
    jinja_tests = {
      lua.text = builtins.readFile ./jinja_tests.lua;
    };
  };
}
