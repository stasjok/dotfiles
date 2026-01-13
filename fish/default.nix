{ lib, ... }:
{
  programs.fish = {
    enable = true;

    loginShellInit = builtins.readFile ./login.fish;
    interactiveShellInit = builtins.readFile ./interactive.fish;

    # Bindings
    binds = {
      ctrl-backspace.command = "backward-kill-token";
      ctrl-h.command = "backward-kill-token";
      alt-backspace.command = "backward-kill-word";
      alt-p.command = "history-token-search-backward";
      alt-n.command = "history-token-search-forward";
      alt-B.command = "backward-bigword";
      alt-F.command = "forward-bigword";
      alt-P.command = "__fish_paginate";
    };

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
                ssh -t root@$salt_hostname ${name} --force-color (bash -c 'printf "%q " "$@"' printf $argv)
              ''
            );
      in
      saltFunctions;
  };
}
