{
  imports = [
    ./ansible_filters.nix
  ];

  snippets.lua = {
    ansible_jinja_stuff.text = builtins.readFile ./ansible_jinja_stuff.lua;
  };
}
