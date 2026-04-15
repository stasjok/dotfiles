{ lib, pkgs, ... }:
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

  # Packages
  home.packages = with pkgs; [
    govc
  ];

  # Disable beancount
  programs.beancount.enable = lib.mkForce false;

  # Nixvim
  programs.nixvim = {
    # CodeCompanion proxy
    plugins.codecompanion.settings.adapters.http.opts.proxy = proxy;

    lsp.servers = {
      # ansible-language-server settings
      ansiblels.config.settings.ansible = {
        ansible.useFullyQualifiedCollectionNames = false;
        completion.provideRedirectModules = lib.mkForce true;
      };
      # disable beancount-lsp-server
      beancount-lsp-server.enable = lib.mkForce false;
    };
  };
}
