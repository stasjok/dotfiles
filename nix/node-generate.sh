#!/bin/bash

set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

node2nix -i node-packages.json -o node-packages.nix -c node-composition.nix
