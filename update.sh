#!/bin/bash

set -e

script_name=$(basename "${BASH_SOURCE[0]}")

cd "$(dirname "${BASH_SOURCE[0]}")"

# Avoid infinite loop
if [[ $1 != --no-pull ]]; then
    git pull
    exec ./"$script_name" --no-pull
fi

nix profile upgrade packages.x86_64-linux.default

ansible-playbook install.yml --extra-vars "force=False"

if [[ -n $TMUX ]]; then
    echo "Sourcing tmux config..."
    tmux source-file ~/.config/tmux/tmux.conf
fi
