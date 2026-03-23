{ lib, ... }:
let
  proxy = "http://rmt4prod.msk.absolutbank.ru:3128";
in
{
  home.sessionVariables = {
    # Proxy settings
    http_proxy = proxy;
    https_proxy = proxy;
    no_proxy = "127.0.0.1,localhost,127.0.0.0/8,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12,absolutbank.ru";
  };

  # Nixvim
  programs.nixvim = {
    # CodeCompanion proxy
    plugins.codecompanion.settings.adapters.http.opts.proxy = proxy;

    # ansible-language-server settings
    lsp.servers.ansiblels.config.settings.ansible = {
      ansible.useFullyQualifiedCollectionNames = false;
      completion.provideRedirectModules = lib.mkForce true;
    };
  };
}
