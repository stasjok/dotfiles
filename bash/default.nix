{
  programs.bash = {
    enable = true;
    historyControl = ["ignorespace" "ignoredups"];

    initExtra = builtins.readFile ./interactive.sh;
    profileExtra = builtins.readFile ./login.sh;
  };
}
