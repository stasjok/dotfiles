{
  stdenv,
  fetchpatch,
  neovim-unwrapped,
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

  patches = [
    # fix(lsp): close floating preview window correctly
    (fetchpatch {
      url = "https://github.com/neovim/neovim/commit/44b8255fa28406d372dc3a7ee4a6afce2514adeb.diff";
      stripLen = 1;
      extraPrefix = "share/nvim/";
      hash = "sha256-fYl7nq7dqlPSBpklFBgOdYr0S/dsQyS4pQ3TwrIlFig=";
    })
    # fix(treesitter): inconsistent highlight of multiline combined injection
    # fixes errors when deleting something at the end of the document
    (fetchpatch {
      url = "https://github.com/neovim/neovim/commit/4b957a4d18d5ffbd969ce82f5c6a0178c2e8e422.diff";
      stripLen = 1;
      extraPrefix = "share/nvim/";
      hash = "sha256-Q6BOEKYIlk+CAG/mm1YWHur4Myeg4CdYa6xRiHP5ZpM=";
    })
  ];

  nativeBuildInputs = [ neovim-unwrapped ];

  buildPhase = ''
    cp -r . $out

    # Regenerate doc tags
    $out/bin/nvim -u NONE -i NONE --cmd "helptags $out/share/nvim/runtime/doc" --cmd q
  '';
}
