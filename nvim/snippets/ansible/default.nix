{ lib, ... }:
{
  imports = [
    ./ansible_filters.nix
  ];

  snippets.lua = {
    ansible_jinja_stuff = lib.singleton {
      text = builtins.readFile ./ansible_jinja_stuff.lua;
    };
  };
}
