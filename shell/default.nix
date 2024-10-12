{
  lib,
  bashInteractive,
  homeConfigurations,
  mkShellNoCC,
  ncurses,
  procps,
}:
let
  # Convert homeConfiguration to devShell (for use in mapAttrs function)
  homeConfigurationToDevShell =
    name: prevConfiguration:
    let
      buildHome = import ./build-home.nix {
        inherit lib;
        homeConfiguration = prevConfiguration;
        targetDirectory = "/tmp/home-configuration-test/${name}/home";
      };
    in
    mkShellNoCC {
      inherit name;
      packages = [
        bashInteractive
        ncurses # fzf-tmux
        procps # find_ssh_agent
      ];
      shellHook = ''
        ${buildHome}
        # Use fish shell if interactive
        if [[ $- = *i* ]]; then
          cd $HOME
          exec $HOME/.nix-profile/bin/fish -l
        fi
      '';
    };

  # Shells
  shells = lib.mapAttrs homeConfigurationToDevShell homeConfigurations;
  extraShells = {
    # Default shell
    default = shells.stas;
    # Shell for tests
    tests =
      let
        name = "tests";
        buildHome = import ./build-home.nix {
          inherit lib;
          homeConfiguration = homeConfigurations.stas;
          targetDirectory = "/tmp/home-configuration-test/${name}/home";
          runOnChangeHooks = false;
        };
      in
      mkShellNoCC {
        inherit name;

        # Locale with UTF-8 support
        LANG = "C.UTF-8";

        shellHook = ''
          ${buildHome}
        '';
      };
  };
in
shells // extraShells
