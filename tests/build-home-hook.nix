{
  lib,
  homeConfiguration,
  targetDirectory,
}: let
  # Library
  inherit (lib) pipe mapAttrsToList;
  inherit (builtins) filter concatStringsSep dirOf;

  configuration = homeConfiguration.override {
    homeDirectory = "${targetDirectory}";
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
in ''
  # Create home directory in TMPDIR
  tmp_home=$(mktemp -d)/home
  cp -rsT --no-preserve=all ${homeFiles}/ $tmp_home
  ln -s ${homePath} $tmp_home/.nix-profile

  # Link persistent home directory to TMPDIR
  mkdir -p ${dirOf homeDirectory}
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
  . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh

  # Execute onChange scripts
  ${onChangeScripts}
''
