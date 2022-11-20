# My dotfiles

## Terminal 

* True Color support is required.
* Set up terminal colors to One Dark theme.
* Install one of the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).

I use [Windows Terminal](https://github.com/microsoft/terminal) and `FiraCode NF` font.
[Settings](wt/settings.json).

## Packages

### First time installation

Install Nix 2.7 and later (https://nixos.org/manual/nix/stable/#chap-installation),
then add to Nix configuration file (`/etc/nix/nix.conf` or `$HOME/.config/nix/nix.conf`):

```
experimental-features = nix-command flakes
```

Install packages:

```bash
nix registry add mypkgs github:stasjok/dotfiles
nix profile install mypkgs
```

### Upgrading

In order to upgrade packages:

```
nix profile upgrade packages.x86_64-linux.default
```

## Installation

Install configs with Ansible:

```
ansible-playbook install.yml
```

It will ask if you want to overwrite existing configs. If you answer `yes`, then all existing
files and directories will be removed. If you answer `no`, then ansible will just fail in case
you already have some configs in place.

## Fish

Change default shell to `/nix/var/nix/profiles/per-user/<USERNAME>/profile/bin/fish`
(or `/usr/bin/fish` if you installed it with package manager).
You may need to edit `/etc/shells`.
