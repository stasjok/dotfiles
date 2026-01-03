{ pkgs, ... }:
{
  lsp.servers = {
    # Bash
    bashls.enable = true;

    # Python
    basedpyright.enable = true;
    ruff.enable = true;

    # Ansible
    ansiblels = {
      enable = true;
      package = pkgs.ansible-language-server;
      config = {
        settings.ansible = {
          completion.provideRedirectModules = false;
        };
      };
    };

    # TypeScript
    vtsls.enable = true;

    # Typos
    typos_lsp.enable = true;

    # Helm language server
    helm_ls.enable = true;

    # Perl
    perlnavigator.enable = true;

    # beancount-lsp-server
    beancount-lsp-server = {
      enable = true;
      name = "beancount-lsp-server";
      package = pkgs.beancount-lsp-server;
      config = {
        cmd = [
          "beancount-lsp-server"
          "--stdio"
        ];
        cmd_env = {
          NODE_OPTIONS = "--max-old-space-size=6144";
        };
        filetypes = [ "beancount" ];
        root_markers = [
          "ledger.beancount"
          ".git"
        ];
        init_options.exclude = [
          "zenmoney/**"
          "easyfinance/**"
        ];
        settings = {
          beanLsp = {
            mainBeanFile = "ledger.beancount";
          };
        };
      };
    };
  };

  extraPackages = with pkgs; [
    # bashls
    shfmt
    # ansiblels
    ansible-lint
  ];
}
