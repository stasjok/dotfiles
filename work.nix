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

  # CodeCompanion proxy
  programs.nixvim.plugins.codecompanion.settings.adapters.http.opts.proxy = proxy;
}
