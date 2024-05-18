{
  inputs,
  lib,
  pkgs,
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
    ];

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
        knownRockspec = runCommand "luv-${version}.rockspec" {} ''
          sed 's/\(version = \)"\(.*\)"/\1"${version}"/' ${prev.luv.knownRockspec} >$out
        '';
      })
      .overrideAttrs (prevAttrs: {
        buildInputs = replaceInput prevAttrs.buildInputs libuv;
      });
    libluv = prev.libluv.overrideAttrs (prevAttrs: {
      inherit (final.luv) version src;
      buildInputs = replaceInput prevAttrs.buildInputs libuv;
    });
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
in
  (neovim-unwrapped.override {
    inherit lua libuv;
  })
  .overrideAttrs {
    pname = "neovim-patched";
    src = inputs.neovim;
  }
