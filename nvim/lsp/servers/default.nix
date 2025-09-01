{ pkgs, helpers, ... }:
{
  lsp.servers = {
    # Python
    basedpyright.enable = true;
    ruff.enable = true;

    # TypeScript
    vtsls.enable = true;

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
        root_markers = [ ".git" ];
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
