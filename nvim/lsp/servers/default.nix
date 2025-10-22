{ pkgs, ... }:
{
  lsp.servers = {
    # Python
    basedpyright.enable = true;
    ruff.enable = true;

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
      settings = {
        cmd = [
          "beancount-lsp-server"
          "--stdio"
        ];
        filetypes = [ "beancount" ];
        root_markers = [
          "ledger.beancount"
          ".git"
        ];
        settings = {
          beanLsp = {
            mainBeanFile = "ledger.beancount";
          };
        };
      };
    };
  };
}
