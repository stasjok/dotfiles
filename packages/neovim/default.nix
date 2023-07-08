{
  fetchpatch,
  neovim-unwrapped,
}:
neovim-unwrapped.overrideAttrs (prev: {
  patches =
    prev.patches
    ++ [
      # fix vim.tbl_get type annotations
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/d3b9feccb39124cefbe4b0c492fb0bc3f777d0b4.diff";
        hash = "sha256-nfuRNcmaJn2AKXywZqbE112VbNDTUfHsbgnPwiiDIZ0=";
      })

      # vim.list_contains and vim.tbl_contains
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/4d04feb6629cb049cb2a13ba35f0c8d3c6b67ff4.diff";
        excludes = ["runtime/doc/news.txt" "runtime/lua/provider/health.lua"];
        hash = "sha256-nY25tMOm/C4xLt75xUShY5JsMvEfLjB4xA1+9QrJS5w=";
      })

      # vim.tbl_islist and vim.tbl_isarray
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/7caf0eafd83b5a92f2ff219b3a64ffae4174b9af.diff";
        excludes = ["runtime/doc/news.txt"];
        hash = "sha256-/ByTAbH5jVjNzX+0lIRa6SNkX2xrl1/QOPhmWD2E3ZM=";
      })

      # vim.keycode
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/7e70ca0b4808bb9d8f19c28c8f93e8f2b9e0d0f0.diff";
        excludes = ["runtime/doc/news.txt"];
        hash = "sha256-CgtawbfttaYDEC9roXk9YVneafp0MyASDcmHktADnE8=";
      })

      # vim.iter
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/ab1edecfb7c73c82c2d5886cb8e270b44aca7d01.diff";
        excludes = ["runtime/doc/news.txt"];
        hash = "sha256-7ScZDAL2+bk1rTA75VfA5LG7MgdonOhsq1pPg7BaDJQ=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/6b96122453fda22dc44a581af1d536988c1adf41.diff";
        hash = "sha256-ZPEEVvKAMMkGXqa/jQQnRNzVL4xTMTm2X54XLfh4tYQ=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/94894068794dbb99804cda689b6c37e70376c8ca.diff";
        hash = "sha256-6P5KM8oCzgFkCxD+JD6fqlFbWz7BV3b/U3yjnrqH4o0=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/f68af3c3bc92c12f7dbbd32f44df8ab57a58ac98.diff";
        hash = "sha256-5QGSSvNkTZuD9tU4TWxsxpj7yH6FGQ5tkJEIied4UjQ=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/1e73891d696a00b046ab19d245001424b174c931.diff";
        hash = "sha256-sw4B6FHREfkkIbW0qIJPtRnjhCI9zL8cIy8Q3ZypGZA=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/147bb87245cdb348e67c659415d0661d48aa5f1e.diff";
        hash = "sha256-gFUNCMx9Z68c5paLsh7wKAqHnb0Q1k2JmPft8zbX43A=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/ef1801cc7c3d8fe9fd8524a3b677095d4437fc66.diff";
        hash = "sha256-OULPSAIO1Z1842F5kBet9lRcClRHOxopIZEkI6drx2g=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/c65e2203f70cd5d66fcb8ffb26f8cef38f50e04f.diff";
        hash = "sha256-/mhelbybPxTo/AQxPAosebTRIoEKz+IJy6roHIMatHk=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/40db569014471deb5bd17860be00d6833387be79.diff";
        hash = "sha256-XmSf9wMzI9Q3Qrnc7V5o9acbML5cttWQd5S6SEfMXWM=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/302d3cfb96d7f0c856262e1a4252d058e3300c8b.diff";
        hash = "sha256-njzF6zcLQZ85STebKCVkfuGE7LptNLd/Es4ZqgbnMbw=";
      })

      # vim.fs.joinpath
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/189fb6203262340e7a59e782be970bcd8ae28e61.diff";
        includes = ["runtime/lua/vim/fs.lua"];
        hash = "sha256-IyvnIh0lwq4cM8kwID+/HTV61sGFQRuq3g/gqrd2spQ=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/e3e6fadfd82861471c32fdcabe00bbef3de84563.diff";
        hash = "sha256-HB7AKd/kONlze+7r6nMBAwE2TgLSC59x9g0NOXowjHg=";
      })

      # vim.ringbuf
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/7c661207cc4357553ed2b057b6c8f28400024361.diff";
        excludes = ["runtime/doc/news.txt"];
        hash = "sha256-Lqn6s6XiKq4ek0H9+m4owSmHU0f8dn0eKOqylTm83yA=";
      })

      # vim.system
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/c0952e62fd0ee16a3275bb69e0de04c836b39015.diff";
        includes = [
          "runtime/doc/lua.txt"
          "runtime/lua/vim/_system.lua"
          "scripts/lua2dox.lua"
          "test/functional/lua/system_spec.lua"
        ];
        hash = "sha256-vQDcA+LW/ooQbUj9q4hBi5PTi6IYXvgQSm4ev6669oM=";
      })
      ./patches/alias-vim-uv-to-vim-loop-and-add-vim-system.patch

      # Enable terminal reflow by default
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/c855eee919f2d4edc9b9fa91b277454290fbabfe.diff";
        excludes = ["runtime/doc/news.txt" "cmake.deps/deps.txt"];
        hash = "sha256-UPLecKSCSaB5y3sPtx0ekG8+aaXJoUiISo5WAoKpGSo=";
      })

      # Restore marks after apply_text_edits
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/5282d3299c9b1b07f3e02a9014bc2632cf3b4fed.diff";
        excludes = ["runtime/doc/news.txt"];
        hash = "sha256-brlesieg2m4G0PTAfrdrACgKoe4kW5IyBdyp7mL2Jzk=";
      })

      # Cache treesitter runtime queries
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/4fd852b8cb88ed035203d3f9ae2e6a8258244974.diff";
        hash = "sha256-sF9BfhvnygZl80daBLUJYARp8lL61oaJhP97BAAwgJI=";
      })

      # Support for dynamic capabilities
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/ddd92a70d2aab5247895e89abaaa79c62ba7dbb4.diff";
        excludes = ["runtime/doc/news.txt"];
        hash = "sha256-Fgk0pDxkoqfmRJlBvi3J5nZPQJpqmumOVq78l7xODeA=";
      })
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/dd3fa645735539c75b72dc1b0114278b5fa57f7f.diff";
        hash = "sha256-FRR65n4CZsVDoz/QfFFDYhvfObJqsfmiD41nNF4a9+Q=";
      })

      # Allow vim.wo to be double indexed
      (fetchpatch {
        url = "https://github.com/neovim/neovim/commit/c379d72c490544b3a56eb0e52ce3c8ef740051d8.diff";
        excludes = ["runtime/doc/news.txt"];
        hash = "sha256-ALIAMsUK9V4yktatdkhYTcPRIH8LUqxN8/+70jNJHV8=";
      })
    ];
})
