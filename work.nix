{
  home.sessionVariables = let
    proxy = "http://rmt4prod.msk.absolutbank.ru:3128";
  in {
    # Proxy settings
    HTTP_PROXY = proxy;
    HTTPS_PROXY = proxy;
    NO_PROXY = "127.0.0.1,localhost,msk.absolutbank.ru";
  };
}
