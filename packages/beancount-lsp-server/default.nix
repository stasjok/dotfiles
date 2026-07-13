{
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_11,
}:
let
  pnpm = pnpm_11;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "beancount-lsp-server";
  version = "0.0.178";

  src =
    (fetchFromGitHub {
      owner = "fengkx";
      repo = "beancount-lsp";
      rev = "v${finalAttrs.version}";
      fetchSubmodules = true;
      hash = "sha256-MRgUpe0UZCPucHkMqza2iFKvTi3x3Wu5rTDqDO2M53Q=";
    }).overrideAttrs
      # fetchgit doesn't have ssh, need http url type
      {
        GIT_CONFIG_COUNT = 1;
        GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
        GIT_CONFIG_VALUE_0 = "git@github.com:";
      };

  patches = [
    ./0001-feat-allow-to-exclude-files-from-ListBeanFiles.patch
    ./0001-disable-filterText-generation.patch
    ./0001-feat-rename-documents-along-with-accounts.patch
    ./remove-reparsing.patch
    ./disable-isincomplete.patch
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
    fetcherVersion = 4;
    hash = "sha256-u1euLl8cVKUeExU0eje+mkEkQvlVntXgvVk3BpUu+gU=";
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
