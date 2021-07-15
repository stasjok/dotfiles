# My dotfiles

## Terminal 

I use [Windows Terminal](https://github.com/microsoft/terminal).

* Set up terminal colors to Solarized Dark theme.
* Install one of the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts). I use `FiraCode NF`.

## Packages

Install Nix (https://nixos.org/manual/nix/stable/#chap-installation), then:

```
nix-env --install --remove-all --file packages.nix
```

## Fish

Change default shell to `/nix/var/nix/profiles/per-user/<USERNAME>/profile/bin/fish`
(or `/usr/bin/fish` if you installed it with package manager).
You may need to edit `/etc/shells`.

## Nvim

Nvim configuration:

```
mkdir -p ~/.local/share/nvim/site/pack/packer.nvim/opt/
ln -s ~/.nix-profile/share/vim-plugins/packer-nvim/ ~/.local/share/nvim/site/pack/packer.nvim/opt/packer.nvim
```

In nvim run command `:Plugins`.
