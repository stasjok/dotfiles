{ pkgs, ... }:
{
  lsp.servers = {
    # Python
    basedpyright.enable = true;
    ruff.enable = true;

    # TypeScript
    vtsls.enable = true;

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
            mainBeanFile = "main.beancount";
          };
        };
      };
    };
  };
}
