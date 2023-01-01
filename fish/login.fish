# Clear old universal variables, because home-manager sets global variables
set -q -U LOCALE_ARCHIVE; and set -e -U LOCALE_ARCHIVE
set -q -U NIX_SSL_CERT_FILE; and set -e -U NIX_SSL_CERT_FILE
set -q -U XDG_DATA_DIRS; and set -e -U XDG_DATA_DIRS
set -q -U MANPATH; and set -e -U MANPATH
set -q -U EDITOR; and set -e -U EDITOR

# Set up ssh-agent
find_ssh_agent

# Disable greeting
set --universal fish_greeting ''
