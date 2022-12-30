{
  lib,
  buildFishPlugin,
  bash,
}:
buildFishPlugin {
  pname = "foreign-env";
  version = "unstable-2022-12-30";

  src = fetchTree {
    type = "github";
    owner = "stasjok";
    repo = "fish-plugin-foreign-env";
    rev = "0cadb087e3c0f7fe935262efd096e9c47ecfbaaf";
    narHash = "sha256-iLrwZke6ajHHgcejLuMAKGDvt+a2Jw6ZxQiw0hzVoM8=";
  };

  preInstall = ''
    sed -e "s|bash|${bash}/bin/bash|" -i functions/fenv.main.fish
  '';

  meta = with lib; {
    description = "A foreign environment interface for Fish shell";
    license = licenses.mit;
    maintainers = with maintainers; [stasjok];
    platforms = with platforms; unix;
  };
}
