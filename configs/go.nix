{ config, ... }:
{
  programs.go = {
    enable = true;
    env.GOBIN = "${config.home.homeDirectory}/.local/bin";
  };
}
