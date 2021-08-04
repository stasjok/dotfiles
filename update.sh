#!/bin/bash

set -e

script_name=$(basename "${BASH_SOURCE[0]}")

cd "$(dirname "${BASH_SOURCE[0]}")"

# Avoid infinite loop
if [[ $1 != --no-pull ]]; then
    git pull
    exec ./"$script_name" --no-pull
fi

nix-env --install --remove-all --file packages.nix

ansible-playbook install.yml --extra-vars "force=True"

nvim --headless -c "autocmd User PackerComplete quitall" -c "runtime lua/my/plugins.lua"
