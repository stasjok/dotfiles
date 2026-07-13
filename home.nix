{
  # Nixvim
  programs.nixvim = {
    # Proxy for adapters
    plugins.codecompanion.settings.adapters.http.opts.proxy = "socks://server.home.stasjok.ru:13128";
  };
}
