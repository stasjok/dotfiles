#!/bin/bash

set -e

script_name=$(basename "${BASH_SOURCE[0]}")

cd "$(dirname "${BASH_SOURCE[0]}")"

# Avoid infinite loop
if [[ $1 != --no-pull ]]; then
    git pull
    exec ./"$script_name" --no-pull
fi

nix profile upgrade defaultPackage.x86_64-linux

ansible-playbook install.yml --extra-vars "force=False"

echo "Syncing neovim plugins with Packer..."
nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerSync"

if [[ -n $TMUX ]]; then
    echo "Sourcing tmux config..."
    tmux source-file ~/.tmux.conf
fi
