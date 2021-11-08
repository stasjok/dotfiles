# My dotfiles

## Terminal 

* True Color support is required.
* Set up terminal colors to One Dark theme.
* Install one of the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).

I use [Windows Terminal](https://github.com/microsoft/terminal) and `FiraCode NF` font.
[Settings](wt/settings.json).

## Packages

Install Nix (https://nixos.org/manual/nix/stable/#chap-installation), then:

```
nix-env --install --remove-all --file packages.nix
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

## Nvim

Run command `:PackerSync` in neovim after first startup. Then restart neovim.
