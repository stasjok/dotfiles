{
  lib,
  homeConfiguration,
  stdenvNoCC,
}:
let
  buildHome = import ../shell/build-home.nix {
    inherit lib homeConfiguration;
    targetDirectory = "/tmp/home";
    runOnChangeHooks = false;
  };
in
stdenvNoCC.mkDerivation {
  name = "tests";
  src = ../.;

  # 'runtimepath' and 'packpath' for minimal_init.lua (Nvim tests)
  inherit (homeConfiguration.config.programs.nixvim.runtime) runtimePaths packPaths;
  inherit (homeConfiguration.config.programs.nixvim.build) initFile;

  # Locale with UTF-8 support
  LANG = "C.UTF-8";

  phases = [
    "unpackPhase"
    "checkPhase"
    "installPhase"
  ];
  doCheck = true;

  checkPhase = ''
    ${buildHome}
    make test
  '';

  installPhase = "touch $out";
}
