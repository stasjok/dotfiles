{ lib, ... }:
let
  proxy = "http://rmt4prod.msk.absolutbank.ru:3128";
in
{
  home.sessionVariables = {
    # Proxy settings
    HTTP_PROXY = proxy;
    HTTPS_PROXY = proxy;
    NO_PROXY = "127.0.0.1,localhost,msk.absolutbank.ru";
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
