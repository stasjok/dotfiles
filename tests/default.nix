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
