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
    yq-go
    # Task runners
    gnumake
    go-task
    lefthook
    # C build tools
    gcc
    autoconf
    automake
    cmake
    bear
    # Ansible
    ansible
    # Kubernetes
    kubectl
    kubernetes-helm
    # Languages
    pythonWithPackages
    nodejs
    nodePackages.typescript
  ];

  # Home Manager
  programs.home-manager.enable = true;

  # User-specific executable files
  home.sessionPath = ["$HOME/.local/bin"];

  # Environment variables
  home.sessionVariables = {
    # Disable HashiCorp checkpoint service (terraform, packer etc)
    CHECKPOINT_DISABLE = 1;
  };

  # ssh-agent
  services.ssh-agent.enable = true;

  # Man
  programs.man = {
    enable = true;
    generateCaches = true;
  };

  # Less, a more advanced file pager than more
  programs.less.enable = true;

  # Exa, a modern replacement for ls
  programs.eza = {
    enable = true;
    enableAliases = true;
  };

  # Jq, command-line JSON processor
  programs.jq.enable = true;
}
