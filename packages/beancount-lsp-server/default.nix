{
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beancount-lsp-server";
  version = "0.0.138";

  src =
    (fetchFromGitHub {
      owner = "fengkx";
      repo = "beancount-lsp";
      rev = "v${finalAttrs.version}";
      fetchSubmodules = true;
      hash = "sha256-Iskf3Ck2NLusYn1c6xN5CW6+1YsCbKmiQJ+ATK4m7zw=";
    }).overrideAttrs
      # fetchgit doesn't have ssh, need http url type
      {
        GIT_CONFIG_COUNT = 1;
        GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
        GIT_CONFIG_VALUE_0 = "git@github.com:";
      };

  patches = [
    ./0001-disable-filterText-generation.patch
    ./0001-fix-add-missing-prepare-rename-for-links.patch
    ./0001-fix-support-renaming-and-finding-references-for-narr.patch
  ];

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  pnpmWorkspaces = [ "${finalAttrs.pname}..." ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    fetcherVersion = 2;
    hash = "sha256-iaNajM4V8tp7ikW4LrxSvTmkR1aRKXyp5YH4o+4k+ok=";
  };

  buildPhase = ''
    runHook preBuild

    # 'tree-sitter-beancount' is excluded from building, because
    # it depends on tree-sitter-cli, which is supposed to download
    # tree-sitter tarball, but it doesn't work in nix.
    # Fortunately tree-sitter-beancount repo already contains
    # tree-sitter-beancount.wasm, so we doesn't actually need to build it
    pnpm \
      --stream \
      --filter="${builtins.elemAt finalAttrs.pnpmWorkspaces 0}" \
      --filter='!@fengkx/tree-sitter-beancount' \
      build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    mkdir $out/bin
    cp packages/lsp-server/dist/node/server.js $out/bin/${finalAttrs.pname}
    patchShebangs --build $out/bin/${finalAttrs.pname}

    runHook postInstall
  '';
})
