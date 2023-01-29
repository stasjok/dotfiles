{
  lib,
  homeConfigurations,
  mkShellNoCC,
  ncurses,
  procps,
}: let
  # Convert homeConfiguration to devShell (for use in mapAttrs function)
  homeConfigurationToDevShell = name: prevConfiguration: let
    buildHomeHook = import ./tests/build-home-hook.nix {
      inherit lib;
      homeConfiguration = prevConfiguration;
      targetDirectory = "/tmp/home-configuration-test/${name}/home";
    };
  in
    mkShellNoCC {
      inherit name;
      packages = [
        ncurses # fzf-tmux
        procps # find_ssh_agent
      ];
      shellHook = ''
        ${buildHomeHook}
        # Use fish shell if interactive
        if [[ $- = *i* ]]; then
          cd $HOME
          exec $HOME/.nix-profile/bin/fish -l
        fi
      '';
    };
in
  lib.mapAttrs homeConfigurationToDevShell homeConfigurations
