if status is-login
    # Set PATH
    set -q fish_user_paths; and set -e fish_user_paths
    fish_add_path --path ~/.nix-profile/bin /nix/var/nix/profiles/default/bin
    # Set EDITOR
    set --universal --export EDITOR nvim
    # Point nix packages to locale archive
    set --universal --export LOCALE_ARCHIVE ~/.nix-profile/lib/locale/locale-archive
    # Set $NIX_SSL_CERT_FILE so that Nixpkgs applications like curl work.
    if not set -q NIX_SSL_CERT_FILE
        if test -e /etc/ssl/certs/ca-certificates.crt # NixOS, Ubuntu, Debian, Gentoo, Arch
            set --universal --export NIX_SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
        else if test -e /etc/ssl/ca-bundle.pem # openSUSE Tumbleweed
            set --universal --export NIX_SSL_CERT_FILE /etc/ssl/ca-bundle.pem
        else if test -e /etc/ssl/certs/ca-bundle.crt # Old NixOS
            set --universal --export NIX_SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
        else if test -e /etc/pki/tls/certs/ca-bundle.crt # Fedora, CentOS
            set --universal --export NIX_SSL_CERT_FILE /etc/pki/tls/certs/ca-bundle.crt
        else if test -e ~/.nix-profile/etc/ssl/certs/ca-bundle.crt
            set --universal --export NIX_SSL_CERT_FILE ~/.nix-profile/etc/ssl/certs/ca-bundle.crt
        end
    end
    # Add nix-profile to the list of XDG data directories
    if not set -q XDG_DATA_DIRS
        set --universal --export --path XDG_DATA_DIRS ~/.nix-profile/share /usr/local/share /usr/share
    else
        set --path XDG_DATA_DIRS (string split : $XDG_DATA_DIRS)
        contains ~/.nix-profile/share $XDG_DATA_DIRS
        or set XDG_DATA_DIRS ~/.nix-profile/share $XDG_DATA_DIRS
    end
    # Add nix-profile to manpath
    set -q MANPATH
    or set --universal --export MANPATH (manpath -q)
    contains ~/.nix-profile/share/man $MANPATH
    or set MANPATH ~/.nix-profile/share/man $MANPATH
    # Set up ssh-agent
    find_ssh_agent
    # Load Theme
    echo y | fish_config theme save "Catppuccin Macchiato"
end

if status is-interactive
    # Disable greeting
    set --universal fish_greeting ''
    # Force True colors
    if string match -q '*-256color' $TERM
        set --global fish_term24bit 1
    end
end
