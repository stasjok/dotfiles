#!/usr/bin/env bash

set -e

dirname=$(dirname "${BASH_SOURCE[0]}")

nixpkgs=$(nix eval --raw --impure --expr "builtins.getFlake (toString ./.)" inputs.nixpkgs.outPath)

nix run .#vimPluginsUpdater -- -i "$dirname/vim-plugin-names" -o "$dirname/generated.nix" \
    --nixpkgs "$nixpkgs" -p 3 --no-commit "$@"
