{ lib, pkgs, ... }:
{
  # Imports
  imports = [
    ./bash
    ./configs
    ./fish
    ./nvim
    ./tmux
  ];

  # Don't generate news
  news = {
    entries = lib.mkForce [ ];
  };

  # Packages
  home.packages =
    with pkgs;
    let
      pythonWithPackages =
        (python3.withPackages (
          p: with p; [
            requests
            pyyaml
            # ansible-language-server uses python to get sys.path in order to get collections list
            ansible
            # beancount-lsp-server uses python to run beancheck
            beancount
          ]
        )).overrideAttrs
          # Avoid collisions with beancount installed in profile
          # TODO: find a better way
          { meta.priority = 10; };
      terraformAlias = stdenvNoCC.mkDerivation {
        pname = "opentofu-alias";
        version = "0.1";
        src = emptyDirectory;
        nativeBuildInputs = [ makeWrapper ];
        buildPhase = ''
          mkdir -p $out/bin
          makeWrapper ${opentofu}/bin/tofu $out/bin/terraform
        '';
      };
    in
    [
      # Command-line tools
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
      # Containers
      podman
      # Kubernetes
      kubectl
      kubernetes-helm
      talosctl
      # Languages
      pythonWithPackages
      opentofu
      terraformAlias
      pulumi
      pulumiPackages.pulumi-nodejs
      pulumiPackages.pulumi-python
      nodejs
      pnpm
      typescript
    ];

  # Home Manager
  programs.home-manager.enable = true;

  # User-specific executable files
  home.sessionPath = [ "$HOME/.local/bin" ];

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
  };

  # Fd, a simple, fast and user-friendly alternative to find
  programs.fd = {
    enable = true;
  };

  # Jq, command-line JSON processor
  programs.jq.enable = true;
}
