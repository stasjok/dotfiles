if status is-login
    # Set PATH
    fish_add_path ~/.nix-profile/bin /nix/var/nix/profiles/default/bin
    # Set EDITOR
    set --universal --export EDITOR nvim
    # Force nix packages to use system locale
    set --universal --export LOCALE_ARCHIVE /usr/lib/locale/locale-archive
    # Set up ssh-agent
    find_ssh_agent
    # Load Solarized Theme
    theme_solarized_dark_load
end

if status is-interactive
    # Disable greeting
    set --universal fish_greeting ''
    # Force True colors
    if string match -q '*-256color' $TERM
        set --global fish_term24bit 1
    end
end
