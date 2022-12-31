#!/usr/bin/env bash

set -e

dirname=$(dirname "${BASH_SOURCE[0]}")

jq=(nix run .#jq --)

flake_url=$(nix flake metadata --json | "${jq[@]}" -e -r .url)
nixpkgs=$(nix eval --raw --impure --expr "(builtins.getFlake \"$flake_url\").inputs.nixpkgs.outPath")

exec "$nixpkgs/pkgs/applications/editors/vim/plugins/update.py" \
    -i "$dirname/vim-plugin-names" -o "$dirname/generated.nix" -p 3 --no-commit "$@"
