{
  snippets.enable = true;

  imports = [
    # Snippet plugin
    ./luasnip.nix

    ./ansible
    ./beancount.nix
    ./gitcommit.nix
    ./jinja
    ./lua.nix
    ./make.nix
    ./mediawiki.nix
    ./nix.nix
    ./python.nix
    ./salt
    ./sh.nix
    ./snippets.nix

    # Lua utils for snippets
    ./utils
  ];
}
