{
  lib,
  gnused,
  mkTmuxPlugin,
}: {
  catppuccin = mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "unstable-2022-12-14";

    src = fetchTree {
      type = "github";
      owner = "catppuccin";
      repo = "tmux";
      rev = "e2561decc2a4e77a0f8b7c05caf8d4f2af9714b3";
      narHash = "sha256-6UmFGkUDoIe8k+FrzdzsKrDHHMNfkjAk0yyc+HV199M=";
    };

    patches = [./catppuccin/dont-create-temporary-files.patch];

    configurePhase = ''
      substituteInPlace catppuccin.tmux --replace sed ${gnused}/bin/sed
    '';

    meta = with lib; {
      description = "Soothing pastel theme for Tmux";
      homepage = "https://github.com/catppuccin/tmux";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };
}
