{
  stdenv,
  neovim-unwrapped,
  fetchpatch,
  fetchurl,
}:

# To avoid re-building neovim just copy attrs and files from original neovim
stdenv.mkDerivation {
  inherit (neovim-unwrapped)
    pname
    version
    lua
    meta
    ;

  src = neovim-unwrapped;

  patches = [
    # 'vim.fs' is compiled into the binary. It's reloaded in patches.nix.
    # fix(vim.fs): root() should always return absolute path
    (fetchpatch {
      url = "https://github.com/neovim/neovim/commit/d974c684da3072345287424d3112209564d7419a.diff";
      stripLen = 1;
      extraPrefix = "share/nvim/";
      excludes = [ "share/nvim/test/functional/lua/fs_spec.lua" ];
      hash = "sha256-rAt4B8i0WEh+lVKvjY9XUySh78MzS1uRlkBhonN/EsU=";
    })
    # fix(vim.fs): abspath(".") returns "/…/."
    (fetchpatch {
      url = "https://github.com/neovim/neovim/commit/6a507bad18a4fb184792a4b36c0f8bd675ce172e.diff";
      stripLen = 1;
      extraPrefix = "share/nvim/";
      excludes = [ "share/nvim/test/functional/lua/fs_spec.lua" ];
      hash = "sha256-mUio6RFH/Mkk+EuXruS7KX6GrBMDCFbwmG7CTCHn0dY=";
    })
  ];

  postPatch = ''
    # Move enabled by default opt plugins to runtime
    # It'll reduce a number of entries in rtp
    local runtime=share/nvim/runtime
    for p in matchit netrw; do
      for d in $runtime/pack/dist/opt/$p/*; do
        [[ -d $d ]] && mv -vt $runtime/''${d##*/} $d/*
      done
      rm -r $runtime/pack/dist/opt/$p
    done
  '';

  nativeBuildInputs = [ neovim-unwrapped ];

  installPhase = ''
    cp -r . $out

    # Regenerate doc tags
    $out/bin/nvim -u NONE -i NONE --cmd "helptags $out/share/nvim/runtime/doc" --cmd q

    # Add luv meta
    mkdir $out/share/nvim/runtime/lua/uv
    cp ${
      fetchurl {
        url = "https://raw.githubusercontent.com/luvit/luv/refs/heads/master/docs/meta.lua";
        hash = "sha256-fTusNw6+LHAY1UFdouhTOLt3MV5rrtqrMLQ6v7WMl2A=";
      }
    } $out/share/nvim/runtime/lua/uv/_meta.lua
  '';
}
