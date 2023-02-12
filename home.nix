{pkgs, ...}: {
  # Imports
  imports = [
    ./bash
    ./configs
    ./fish
    ./nvim
    ./tmux
  ];

  # Packages
  home.packages = with pkgs; let
    pythonWithPackages = python3.withPackages (p:
      with p; [
        requests
        pyyaml
        # ansible-language-server uses python to get sys.path in order to get collections list
        ansible
      ]);
  in [
    # Command-line tools
    fd
    ripgrep
    # Task runners
    gnumake
    go-task
    # Ansible
    ansible_2_12
    # Languages
    pythonWithPackages
    terraform
    nodejs
    go
    nodePackages.typescript
  ];

  # Home Manager
  programs.home-manager.enable = true;

  # Man
  programs.man = {
    enable = true;
    generateCaches = true;
  };

  # Less, a more advanced file pager than more
  programs.less.enable = true;

  # Exa, a modern replacement for ls
  programs.exa = {
    enable = true;
    enableAliases = true;
  };
}