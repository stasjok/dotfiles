# My dotfiles

## Terminal

- True Color support is required.
- Set up terminal colors to [Catppuccin macchiato](https://github.com/catppuccin/catppuccin).
- Install one of the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).

I use [Windows Terminal](https://github.com/microsoft/terminal)
and `FiraCode NF` font. [Settings](wt/settings.json).

## Home configuration

My dotfiles are managed with [Home Manager](https://nix-community.github.io/home-manager/)
and [Nix package manager](https://nixos.org/manual/nix/stable/introduction.html).

### First time configuration

Install Nix 2.7 or later (<https://nixos.org/manual/nix/stable/installation/installing-binary.html>).

Activate configuration:

```bash
nix --extra-experimental-features "nix-command flakes" run \
    github:stasjok/dotfiles#home-manager -- --flake github:stasjok/dotfiles \
    --extra-experimental-features "nix-command flakes" switch
```

### Upgrading

In order to upgrade configuration:

```bash
home-manager switch --flake dotfiles 
```

## Shell

Change default shell to `/nix/var/nix/profiles/per-user/<USERNAME>/profile/bin/fish`.
You also may need to edit `/etc/shells`.

## Developing

### Try before installing

Run interactive fish shell with all packages available:

```bash
nix develop -i -k TERM dotfiles
```

Run *neovim* in current directory:

```bash
nix develop -i -k TERM dotfiles -c nvim
```

Note that it will use `/tmp/home-configuration-test` as a temporary home directory.
