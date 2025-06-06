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
  extraShells =
    let
      testHomeConfiguration = homeConfigurations.stas;
      testEnv = {
        # Pass 'runtimepath', 'packpath' and init.lua paths to Nvim test runner
        inherit (testHomeConfiguration.config.programs.nixvim.runtime) runtimePaths packPaths;
        inherit (testHomeConfiguration.config.programs.nixvim.build) initFile;

        # Locale with UTF-8 support
        LANG = "C.UTF-8";
      };
    in
    {
      # Default shell
      default = shells.stas;
      # Shell for tests
      tests =
        let
          name = "tests";
          buildHome = import ./build-home.nix {
            inherit lib;
            homeConfiguration = testHomeConfiguration;
            targetDirectory = "/tmp/home-configuration-test/${name}/home";
            runOnChangeHooks = false;
          };
        in
        mkShellNoCC (
          {
            inherit name;

            shellHook = ''
              ${buildHome}
            '';
          }
          // testEnv
        );
      # Shell for Nvim tests
      nvimTests = mkShellNoCC (
        {
          name = "nvim-tests";
          packages = [
            testHomeConfiguration.config.home.path
          ];
          shellHook = ''
            export HOME=$(mktemp -d)
            export USER="${testHomeConfiguration.config.home.username}"
            export XDG_RUNTIME_DIR=$(mktemp -d)
          '';
        }
        // testEnv
      );
    };
in
shells // extraShells
