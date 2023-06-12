{
  lib,
  buildFishPlugin,
  bash,
}:
buildFishPlugin {
  pname = "foreign-env";
  version = "unstable-2023-01-14";

  src = fetchTree {
    type = "github";
    owner = "oh-my-fish";
    repo = "plugin-foreign-env";
    rev = "3ee95536106c11073d6ff466c1681cde31001383";
    narHash = "sha256-vyW/X2lLjsieMpP9Wi2bZPjReaZBkqUbkh15zOi8T4Y=";
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
