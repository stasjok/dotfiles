#!/bin/bash

set -e

script_name=$(basename "${BASH_SOURCE[0]}")

cd "$(dirname "${BASH_SOURCE[0]}")"

# Avoid infinite loop
if [[ $1 != --no-pull ]]; then
    # Right now packer doesn't fetch new commits before checking out, but it
    # does fetch commits after. So before we pull new updates we sync plugins.
    # https://github.com/wbthomason/packer.nvim/issues/558
    nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerSync"

    git pull
    exec ./"$script_name" --no-pull
fi

nix-env --install --remove-all --file packages.nix

ansible-playbook install.yml --extra-vars "force=False"

echo "Syncing neovim plugins with Packer..."
nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerSync"

if [[ -n $TMUX ]]; then
    echo "Sourcing tmux config..."
    tmux source-file ~/.tmux.conf
fi
