{ pkgs, helpers, ... }:
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
        init_options.debounceTime = 1200;
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
        # This server provides wrong capabilities in InitializeResult
        # It sends its capabilities with client/registerCapability, but Nvim doesn't support
        # dynamic registration for most capabilities
        on_init = helpers.mkRaw ''
          function(client)
            client.server_capabilities.completionProvider.triggerCharacters = { "2", "#", '"', "^" }
          end
        '';
      };
    };
  };
}
