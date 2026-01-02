{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Stanislav Asunkin";
        email = "1353637+stasjok@users.noreply.github.com";
      };

      alias = {
        tree = "log --oneline --decorate --all --graph";
      };

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

    ignores = [
      "*.swp"
      "*.swo"
      "*.swn"
    ];

    # Delta
    delta = {
      enable = true;
      options = {
        true-color = "always";
      };
    };
  };
}
