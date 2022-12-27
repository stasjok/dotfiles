# My dotfiles

## Terminal

- True Color support is required.
- Set up terminal colors to [Catppuccin macchiato](https://github.com/catppuccin/catppuccin).
- Install one of the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).

I use [Windows Terminal](https://github.com/microsoft/terminal)
and `FiraCode NF` font. [Settings](wt/settings.json).

## Packages

### First time configuration

Install Nix 2.7 and later (<https://nixos.org/manual/nix/stable/installation/installing-binary.html>),
then add to Nix configuration file (`/etc/nix/nix.conf` or `$HOME/.config/nix/nix.conf`):

```ini
experimental-features = nix-command flakes
```

Activate configuration:

```bash
nix registry add dotfiles github:stasjok/dotfiles
nix run dotfiles#home-manager -- --flake dotfiles switch
```

### Upgrading

In order to upgrade configuration:

```bash
home-manager --flake dotfiles switch
```

## Fish

Change default shell to `/nix/var/nix/profiles/per-user/<USERNAME>/profile/bin/fish`
(or `/usr/bin/fish` if you installed it with package manager).
You may need to edit `/etc/shells`.
