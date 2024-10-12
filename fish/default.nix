{ lib, ... }:
{
  programs.fish = {
    enable = true;

    loginShellInit = builtins.readFile ./login.fish;
    interactiveShellInit = builtins.readFile ./interactive.fish;

    # Functions
    functions =
      let
        funcWithDesc = description: body: { inherit body description; };
        # Salt functions
        saltFunctions =
          lib.genAttrs
            [
              "salt"
              "salt-cp"
              "salt-key"
              "salt-run"
              "salt-ssh"
              "salt-unity"
            ]
            (
              name:
              funcWithDesc "Run ${name} command over SSH" ''
                test -z $salt_hostname; and read -U -P "Enter Salt hostname: " salt_hostname
                ssh -t root@$salt_hostname ${name} --force-color (string escape -- $argv)
              ''
            );
      in
      {
        # Custom bindings
        fish_user_key_bindings = ''
          bind \ep history-token-search-backward
          bind \en history-token-search-forward
          bind \eB backward-bigword
          bind \eF forward-bigword
          bind \eP __fish_paginate
        '';

        # My current dev neovim configuration
        nvim-dev = "nix develop -i -k TERM -k TERM_PROGRAM -k TMUX dotfiles -c nvim $argv";
      }
      // saltFunctions;
  };
}
