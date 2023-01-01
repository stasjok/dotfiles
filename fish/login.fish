# Disable greeting
set -U fish_greeting ''

# Ensure that $NIX_PROFILES is always set, because it's used for setting
# default search paths for completions and functions.
# See $__fish_data_dir/config.fish and $__fish_data_dir/__fish_build_paths.fish.
if set -qg NIX_PROFILES
    set -U NIX_PROFILES $NIX_PROFILES
else
    set -U NIX_PROFILES "/nix/var/nix/profiles/default $HOME/.nix-profile"
end

# Set up ssh-agent
find_ssh_agent

# Clear old universal variables, because home-manager sets global variables
set -q -U LOCALE_ARCHIVE; and set -e -U LOCALE_ARCHIVE
set -q -U NIX_SSL_CERT_FILE; and set -e -U NIX_SSL_CERT_FILE
set -q -U XDG_DATA_DIRS; and set -e -U XDG_DATA_DIRS
set -q -U MANPATH; and set -e -U MANPATH
set -q -U EDITOR; and set -e -U EDITOR
