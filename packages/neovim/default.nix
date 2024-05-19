{
  inputs,
  lib,
  pkgs,
  autoreconfHook,
  fetchurl,
  luajit,
  neovim-unwrapped,
  runCommand,
  stdenvNoCC,
}: let
  # Convert neovim's deps.txt to attrset
  deps = lib.pipe "${inputs.neovim}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (builtins.filter (s: s != ""))
    (map (s: lib.splitString " " s))
    (map (list: {
      name = builtins.elemAt list 0;
      value = builtins.elemAt list 1;
    }))
    builtins.listToAttrs
  ];

  # Get filename from URL without .tar extension and 'v' prefix
  versionFromURL = url:
    lib.pipe url [
      (lib.flip lib.nameFromURL ".tar")
      (lib.removePrefix "v")
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
    version = versionFromURL deps.LIBUV_URL;
    src = fetchurl {
      url = deps.LIBUV_URL;
      sha256 = deps.LIBUV_SHA256;
    };
  };

  # luv
  luaPackageOverrides = final: prev: {
    luv =
      (prev.luaLib.overrideLuarocks prev.luv rec {
        version = lib.removePrefix "luv-" (versionFromURL deps.LUV_URL);
        src = fetchurl {
          url = deps.LUV_URL;
          sha256 = deps.LUV_SHA256;
        };
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
      version = lib.removePrefix "lpeg-" (versionFromURL deps.LPEG_URL);
      src = fetchurl {
        url = deps.LPEG_URL;
        sha256 = deps.LPEG_SHA256;
      };
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
    src = fetchurl {
      url = deps.LUAJIT_URL;
      sha256 = deps.LUAJIT_SHA256;
    };
    packageOverrides = luaPackageOverrides;
    self = lua;
  };

  # MessagePack for C
  msgpack-c = pkgs.msgpack-c.overrideAttrs {
    version = lib.pipe deps.MSGPACK_URL [
      versionFromURL
      (lib.removePrefix "msgpack-")
      (lib.removePrefix "c-")
    ];
    src = fetchurl {
      url = deps.MSGPACK_URL;
      sha256 = deps.MSGPACK_SHA256;
    };
  };

  # Unibilium
  unibilium = pkgs.unibilium.overrideAttrs (prev: {
    version = versionFromURL deps.UNIBILIUM_URL;
    src = fetchurl {
      url = deps.UNIBILIUM_URL;
      sha256 = deps.UNIBILIUM_SHA256;
    };
    # autoreconf is needed for newer versions to generate Makefile
    nativeBuildInputs = lib.unique (prev.nativeBuildInputs ++ [autoreconfHook]);
  });

  # libvterm neovim fork
  libvterm-neovim = pkgs.libvterm-neovim.overrideAttrs {
    version = versionFromURL deps.LIBVTERM_URL;
    src = fetchurl {
      url = deps.LIBVTERM_URL;
      sha256 = deps.LIBVTERM_SHA256;
    };
  };
in
  (neovim-unwrapped.override {
    inherit libuv lua msgpack-c unibilium libvterm-neovim;
    # not needed dependencies
    libtermkey = null;
    gperf = null;
    ncurses = null;
  })
  .overrideAttrs (prev: {
    pname = "neovim-patched";
    src = inputs.neovim;
  })
