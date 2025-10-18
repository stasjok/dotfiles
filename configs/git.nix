{
  programs.git = {
    enable = true;

    userName = "Stanislav Asunkin";
    userEmail = "1353637+stasjok@users.noreply.github.com";

    aliases = {
      tree = "log --oneline --decorate --all --graph";
    };

    ignores = [
      "*.swp"
      "*.swo"
      "*.swn"
    ];

    extraConfig = {
      # Cache credentials
      credential.helper = "cache --timeout 3600";

      # Allow only fast-forward merges when pulling
      pull.ff = "only";

      # A style for conflicted hunks
      merge.conflictStyle = "zdiff3";

      # Enable autostash
      rebase.autoStash = true;
      merge.autoStash = true;

      # Git status
      status.showUntrackedFiles = "all";

      # Git diff
      diff = {
        colorMoved = "default";
        colorMovedWS = "allow-indentation-change";
      };

      # Avoid requiring ssh keys
      url."https://github.com/".insteadOf = "git@github.com:";
    };

    # Delta
    delta = {
      enable = true;
      options = {
        true-color = "always";
      };
    };
  };
}
