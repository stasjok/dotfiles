{ config, ... }:
{
  # Nixvim
  programs.nixvim = {
    # Proxy for Jina adapter
    plugins.codecompanion.settings.adapters.http.jina = config.lib.nixvim.mkRaw ''
      require("codecompanion.adapters.http").extend("jina", ${
        config.lib.nixvim.toLuaObject { opts.proxy = "socks://server.home.stasjok.ru:13128"; }
      })
    '';
  };
}
