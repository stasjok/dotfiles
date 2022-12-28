{
  config,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;

    loginShellInit = builtins.readFile ./login.fish;
    interactiveShellInit = builtins.readFile ./interactive.fish;

    # Functions
    functions = let
      funcWithDesc = description: body: {inherit body description;};
      # Salt functions
      saltFunctions =
        lib.genAttrs [
          "salt"
          "salt-cp"
          "salt-key"
          "salt-run"
          "salt-ssh"
          "salt-unity"
        ] (name:
          funcWithDesc "Run ${name} command over SSH" ''
            test -z $salt_hostname; and read -U -P "Enter Salt hostname: " salt_hostname
            ssh -t root@$salt_hostname ${name} --force-color (string escape -- $argv)
          '');
    in
      {
        # Custom bindings
        fish_user_key_bindings = ''
          bind \ep history-token-search-backward
          bind \en history-token-search-forward
          bind \eB backward-bigword
          bind \eF forward-bigword
          bind \eP __fish_paginate
        '';

        find_ssh_agent =
          funcWithDesc "Find or run ssh-agent"
          (builtins.readFile ./functions/find_ssh_agent.fish);

        # Copy to tmux
        fish_clipboard_copy = builtins.readFile ./functions/fish_clipboard_copy.fish;
      }
      // saltFunctions;
  };

  # Catppuccin Macchiato theme
  xdg.configFile."fish/themes" = let
    src = fetchTree {
      type = "github";
      owner = "catppuccin";
      repo = "fish";
      rev = "8d0b07ad927f976708a1f875eb9aacaf67876137";
      narHash = "sha256-/JIKRRHjaO2jC0NNPBiSaLe8pR2ASv24/LFKOJoZPjk=";
    };
  in {
    source = "${src}/themes";
    recursive = true;
    onChange = ''
      ${config.programs.fish.package}/bin/fish <<"EOF"
      echo y | fish_config theme save 'Catppuccin Macchiato'
      # Override colors
      set fish_color_comment 8087a2 --italic
      set fish_color_host_remote 8aadf4
      set fish_color_status ed8796
      EOF
    '';
  };
}
