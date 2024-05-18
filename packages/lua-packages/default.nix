{fetchurl}: final: prev: {
  # luv version matching neovim 0.10
  luv = prev.luaLib.overrideLuarocks prev.luv {
    version = "1.48.0-2";
    knownRockspec = fetchurl {
      url = "mirror://luarocks/luv-1.48.0-2.rockspec";
      sha256 = "sha256-JPnLAlsAOrBcyF21vWAYrS2XWnZNz3waDAqkn6xcoww=";
    };
    src = fetchurl {
      url = "https://github.com/luvit/luv/releases/download/1.48.0-2/luv-1.48.0-2.tar.gz";
      sha256 = "sha256-LDod3+u09lUCk6QO54n3Ei6XZH7t5RUR9XID3kjAO3o=";
    };
  };
  libluv = prev.libluv.overrideAttrs {
    inherit (final.luv) version src;
  };
}
