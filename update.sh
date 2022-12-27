#!/bin/bash

set -e

script_name=$(basename "${BASH_SOURCE[0]}")

script_dir=$(dirname "${BASH_SOURCE[0]}")
cd "$script_dir"

# Avoid infinite loop
if [[ $1 != --no-pull ]]; then
    git pull
    exec ./"$script_name" --no-pull
fi

home_manager=(home-manager)

# Migrate from old configuration
if ! command -v home-manager >/dev/null; then
    for dir in bat fish git nvim tmux; do
        path=${XDG_CONFIG_HOME:-$HOME/.config}/$dir
        if [[ -L $path && $(readlink "$path") = $script_dir/$dir ]]; then
            rm -v "$path"
        fi
    done
    nix=$(realpath "$(command -v nix)")
    # Remove old nix-profile package
    nix profile remove packages.x86_64-linux.default || true
    # Make sure that nix in PATH
    hash -d nix
    command -v nix >/dev/null || PATH="${nix%/*}:$PATH"
    home_manager=(nix run .#home-manager --)
fi

"${home_manager[@]}" --flake . switch
