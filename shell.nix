{
  lib,
  homeConfigurations,
  mkShellNoCC,
}: let
  # Library
  inherit (lib) pipe mapAttrsToList;
  inherit (builtins) filter mapAttrs concatStringsSep;

  # Convert homeConfiguration to devShell (for using in mapAttrs function)
  homeConfigurationToDevShell = name: prevConfiguration: let
    tmpDir = "/tmp/home-configuration-test/${name}";
    configuration = prevConfiguration.override {
      homeDirectory = "${tmpDir}/home";
    };
    inherit (configuration) config;
    inherit (config.home) username homeDirectory;
    homePath = config.home.path;
    homeFiles = config.home-files;
    onChangeScripts = pipe config.home.file [
      (mapAttrsToList (name: file: file.onChange))
      (filter (s: s != ""))
      (concatStringsSep "\n")
    ];
  in
    mkShellNoCC {
      inherit name;
      shellHook = ''
        # Create home directory in TMPDIR
        tmp_home=$TMPDIR/home
        cp -rsT --no-preserve=all ${homeFiles}/ $tmp_home
        ln -s ${homePath} $tmp_home/.nix-profile
        mkdir -p ${tmpDir}

        # Link persistent home directory to TMPDIR
        ln -sfT $tmp_home ${homeDirectory}
        unset tmp_home

        # Create runtime dir
        runtime_dir=$TMPDIR/run
        mkdir -p $runtime_dir
        chmod 700 $runtime_dir

        # Export variables
        export HOME=${homeDirectory}
        export USER=${username}
        export XDG_RUNTIME_DIR=$runtime_dir
        unset runtime_dir
        [[ $TERM = dumb ]] && export TERM=xterm-256color
        . $HOME/.nix-profile/etc/profile.d/nix.sh

        # Execute onChange scripts
        ${onChangeScripts}

        # Use fish shell if interactive
        if [[ $- = *i* ]]; then
          cd $HOME
          exec $HOME/.nix-profile/bin/fish
        fi
      '';
    };
in
  mapAttrs homeConfigurationToDevShell homeConfigurations
