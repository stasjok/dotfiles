{ inputs }:
final: prev:
let
  inherit (prev) lib;
  # Add flake inputs to autoArgs
  callPackage = lib.callPackageWith (final // { inherit inputs; });
in
{
  # Nvim
  neovim-patched = callPackage ../packages/neovim-patched { };

  # Fish plugins
  fishPlugins = prev.fishPlugins.overrideScope (callPackage ../packages/fish-plugins { });

  # Tmux plugins
  tmuxPlugins =
    prev.tmuxPlugins
    // (callPackage ../packages/tmux-plugins { inherit (final.tmuxPlugins) mkTmuxPlugin; });

  # Vim plugins
  vimPlugins = prev.vimPlugins.extend (callPackage ../packages/vim-plugins { });

  # Python packages
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (callPackage ../packages/python-packages { })
  ];

  # Lua interpreters and packages
  luaInterpreters = lib.fix (
    lib.extends (callPackage ../packages/lua-interpreters { }) (_: prev.luaInterpreters)
  );

  # Node packages
  nodePackages = prev.nodePackages.extend (callPackage ../packages/node-packages { });

  # Tree-sitter grammars
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-jinja2 = {
        src = inputs.tree-sitter-jinja2;
      };
    };
  };

  # Avoid binary clashing with nixfmt-rfc-style
  nixfmt-classic = prev.runCommand "nixfmt-classic" { } ''
    mkdir -p $out/bin
    ln -s ${lib.getBin prev.nixfmt-classic}/bin/nixfmt $out/bin/nixfmt-classic
  '';

  # Allow changing kubernetes schema URL via settings
  yaml-language-server = prev.yaml-language-server.overrideAttrs {
    src = inputs.yaml-language-server;
  };

  # Freeze packer to the letest version with Mozilla Public License 2.0
  packer = callPackage ../packages/packer { };
}
