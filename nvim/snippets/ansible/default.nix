{
  imports = [
    ./ansible_filters.nix
  ];

  snippets.filetype = {
    ansible_jinja_stuff = {
      lua.text = builtins.readFile ./ansible_jinja_stuff.lua;
    };
  };
}
