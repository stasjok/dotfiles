{ fetchurl, fetchzip }:
final: prev: {
  # Update luasnip to fix deprecated usage of vim.validate
  luasnip = final.luaLib.overrideLuarocks prev.luasnip {
    version = "2.4.0-1";
    knownRockspec = fetchurl {
      url = "mirror://luarocks/luasnip-2.4.0-1.rockspec";
      sha256 = "0rbv9z1bb8dy70mmy7w621zlhxcdv1g3bmmdxp012hicg7zrikyy";
    };
    src = fetchzip {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/v2.4.0.zip";
      sha256 = "055mbyszd7gyxib4yi4wsiazs63p4d6ms3sp6x7xya7d0szfkl0n";
    };
  };
}
