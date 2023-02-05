{
  lib,
  homeConfiguration,
  neovim-unwrapped,
  neovimUtils,
  stdenvNoCC,
  vimPlugins,
  wrapNeovimUnstable,
}: let
  # Library
  inherit (lib) escapeShellArgs;

  # Test environment
  testEnv = name: test: let
    buildHomeHook = import ./build-home-hook.nix {
      inherit lib homeConfiguration;
      targetDirectory = "/tmp/home";
      runOnChangeHooks = false;
    };
  in
    stdenvNoCC.mkDerivation {
      name = name;
      src = ../.;
      phases = ["unpackPhase" "checkPhase" "installPhase"];

      checkPhase = ''
        ${buildHomeHook}
        export LANG=C.UTF-8
        ${test}
      '';
      doCheck = true;

      installPhase = "touch $out";
    };

  # Neovim with test frameworks integrated
  headlessNeovimPackage = let
    neovimConfig = neovimUtils.makeNeovimConfig {
      withPython3 = false;
      withRuby = false;
      withNodeJs = false;
      plugins = with vimPlugins; [
        {
          plugin = plenary-nvim;
          config = "runtime plugin/plenary.vim";
        }
        {
          plugin = mini-nvim;
          config = "lua require('mini.test').setup()";
        }
      ];
      customRC = ''
        let g:did_load_filetypes = 1
        syntax off
      '';
    };
  in
    (wrapNeovimUnstable neovim-unwrapped neovimConfig).override (prev: {
      wrapperArgs = prev.wrapperArgs ++ ["--add-flags" "--headless --noplugin -n -i NONE"];
    });
  headlessNeovim = "${headlessNeovimPackage}/bin/nvim";

  # Run tests with plenary
  plenaryBusted = directory:
    escapeShellArgs [
      headlessNeovim
      "-c"
      "lua require('plenary.test_harness').test_directory('${directory}', {minimal_init = 'tests/nvim/minimal_init.lua', nvim_cmd = 'nvim'})"
    ];

  # Run tests with MiniTest
  miniTest = directory:
    escapeShellArgs [
      headlessNeovim
      "-c"
      "lua MiniTest.run({collect = {find_files = function() return vim.fn.globpath('${directory}', '**/test_*.lua', true, true) end}})"
    ];
in {
  nvim-unit = testEnv "test-nvim-unit" ''
    ${plenaryBusted "tests/nvim/unit"}
  '';
  nvim-integration = testEnv "test-nvim-integration" ''
    ${plenaryBusted "tests/nvim/integration"}
    ${miniTest "tests/nvim/integration"}
  '';
  nvim-functional = testEnv "test-nvim-integration" ''
    ${headlessNeovim} -c "lua require('plenary.test_harness').test_directory('tests/nvim/functional', {nvim_cmd = 'nvim'})"
    ${miniTest "tests/nvim/functional"}
  '';
}
