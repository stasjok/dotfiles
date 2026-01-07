{ config, lib, ... }:
let
  cfg = config.programs.gh;
in
{
  programs = {
    gh.enable = true;

    # Home-manager's default gitCredentialHelper resets global helper,
    # but I want this helper only as fallback
    gh.gitCredentialHelper.enable = false;
    git.settings.credential = builtins.listToAttrs (
      map (
        host:
        lib.nameValuePair host {
          helper = [
            "${cfg.package}/bin/gh auth git-credential"
          ];
        }
      ) cfg.gitCredentialHelper.hosts
    );

    gh-dash.enable = true;
  };
}
