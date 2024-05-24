{
  inputs,
  lib,
  pkgs,
  applyPatches,
  autoreconfHook,
  fetchpatch,
  fetchurl,
  luajit,
  neovim-unwrapped,
  runCommand,
  stdenvNoCC,
}: let
  # Neovim patches
  patches = [
    # perf(treesitter): use child_containing_descendant() in has-ancestor?
    (fetchpatch {
      url = "https://github.com/neovim/neovim/commit/4b029163345333a2c6975cd0dace6613b036ae47.diff";
      hash = "sha256-X/nnIDAalYPZvMVCfMtZhouQ9Xw3knSGOiMR6xHBOYY=";
    })
    # fix(vim.iter): enable optimizations for arrays (lists with holes)
    (fetchpatch {
      url = "https://github.com/neovim/neovim/commit/4c0d18c19773327dcd771d1da7805690e3e41255.diff";
      hash = "sha256-WKxMbXuK6hWzU2o5hT7VjG9GpfuKg24AwsJ10TkzGE8=";
    })
  ];

  # Neovim source
  src = applyPatches {
    name = "neovim-source";
    src = inputs.neovim;
    inherit patches;
    patchFlags = ["-p1" "--no-backup-if-mismatch"];
  };

  # Convert neovim's deps.txt to attrset of sources
  deps = lib.pipe "${inputs.neovim}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (map (builtins.match "([[:alnum:]_]+)_(URL|SHA256)[[:blank:]]+([^[:blank:]]+)[[:blank:]]*"))
    (lib.remove null)
    (builtins.foldl' (acc: elem: let
      name = lib.toLower (builtins.elemAt elem 0);
      key = lib.toLower (builtins.elemAt elem 1);
      value = builtins.elemAt elem 2;
    in
      lib.recursiveUpdate acc {${name}.${key} = value;}) {})
    (builtins.mapAttrs (_: attrs: fetchurl attrs))
  ];

  # Get src version or 12 characters from filename without 'v' prefix
  versionFromSrc = src:
    lib.pipe src.name [
      # Remove .tar.* extension
      (lib.splitString ".tar.")
      builtins.head
      builtins.parseDrvName
      (parsed:
        if parsed.version != ""
        then parsed.version
        else lib.removePrefix "v" parsed.name)
      (builtins.substring 0 12)
    ];

  # Update version in rockspec file
  rockspecUpdateVersion = orig: name: version: let
    # Revision is required after version
    v =
      if lib.hasInfix "-" version
      then version
      else "${version}-1";
  in
    runCommand "${name}-${v}.rockspec" {} ''
      sed -E "s/(version[[:blank:]]*=[[:blank:]]*[\"'])(.*)([\"'])/\1${v}\3/" ${orig} >$out
    '';

  # Remove original and append overriden derivation to a list
  replaceInput = prev: drv: builtins.filter (i: lib.getName i != lib.getName drv) prev ++ [drv];

  # libuv
  libuv = pkgs.libuv.overrideAttrs {
    version = versionFromSrc deps.libuv;
    src = deps.libuv;
  };

  # luv
  luaPackageOverrides = final: prev: {
    luv =
      (prev.luaLib.overrideLuarocks prev.luv rec {
        version = versionFromSrc deps.luv;
        src = deps.luv;
        # Update version in rockspec file
        knownRockspec = rockspecUpdateVersion prev.luv.knownRockspec "luv" version;
      })
      .overrideAttrs (prevAttrs: {
        buildInputs = replaceInput prevAttrs.buildInputs libuv;
      });
    libluv = prev.libluv.overrideAttrs (prevAttrs: {
      inherit (final.luv) version src;
      buildInputs = replaceInput prevAttrs.buildInputs libuv;
    });
    lpeg = prev.luaLib.overrideLuarocks prev.lpeg rec {
      version = versionFromSrc deps.lpeg;
      src = deps.lpeg;
      knownRockspec = rockspecUpdateVersion prev.lpeg.knownRockspec "lpeg" version;
    };
  };

  # LuaJIT
  lua = luajit.override rec {
    version = let
      relverFile = stdenvNoCC.mkDerivation {
        name = "luajit-relver";
        inherit src;
        phases = ["unpackPhase" "installPhase"];
        installPhase = "cp .relver $out";
      };
      relver = lib.fileContents relverFile;
    in
      "2.1." + relver;
    src = deps.luajit;
    packageOverrides = luaPackageOverrides;
    self = lua;
  };

  # MessagePack for C
  msgpack-c = pkgs.msgpack-c.overrideAttrs {
    version = versionFromSrc deps.msgpack;
    src = deps.msgpack;
  };

  # Unibilium
  unibilium = pkgs.unibilium.overrideAttrs (prev: {
    version = versionFromSrc deps.unibilium;
    src = deps.unibilium;
    # autoreconf is needed for newer versions to generate Makefile
    nativeBuildInputs = lib.unique (prev.nativeBuildInputs ++ [autoreconfHook]);
  });

  # libvterm neovim fork
  libvterm-neovim = pkgs.libvterm-neovim.overrideAttrs {
    version = versionFromSrc deps.libvterm;
    src = deps.libvterm;
  };

  # Tree-sitter
  tree-sitter = pkgs.tree-sitter.overrideAttrs (prev: rec {
    version = versionFromSrc deps.treesitter;
    src = deps.treesitter;
    # Need to update cargo hash every time
    cargoHash = "sha256-U2YXpNwtaSSEftswI0p0+npDJqOq5GqxEUlOPRlJGmQ=";
    cargoDeps = prev.cargoDeps.overrideAttrs {
      inherit src;
      hash = cargoHash;
      outputHash = cargoHash;
    };
  });

  # Tree-sitter parsers
  treesitter-parsers = lib.pipe deps [
    (lib.filterAttrs (key: _: lib.hasPrefix "treesitter_" key))
    (lib.mapAttrs' (name: src: lib.nameValuePair (lib.removePrefix "treesitter_" name) {src = src;}))
  ];
in
  (neovim-unwrapped.override {
    inherit libuv lua msgpack-c unibilium libvterm-neovim tree-sitter;
    inherit treesitter-parsers;
  })
  .overrideAttrs (prev: {
    pname = "neovim-patched";
    version = let
      cmakeLists = builtins.readFile "${src}/CMakeLists.txt";
      getValue = name: builtins.head (builtins.match ''.*\(${name} "?([^)"]*)"?\).*'' cmakeLists);
      major = getValue "NVIM_VERSION_MAJOR";
      minor = getValue "NVIM_VERSION_MINOR";
      patch = getValue "NVIM_VERSION_PATCH";
      prerelease = getValue "NVIM_VERSION_PRERELEASE";
    in "${major}.${minor}.${patch}${prerelease}";
    inherit src;
  })
