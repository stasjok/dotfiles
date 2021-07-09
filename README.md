# My dotfiles

## Packages

Install Nix (https://nixos.org/manual/nix/stable/#chap-installation), then:

```
nix-env --install --remove-all --file packages.nix
```

## Nvim

Nvim configuration:

```
mkdir -p ~/.local/share/nvim/site/pack/packer.nvim/opt/
ln -s ~/.nix-profile/share/vim-plugins/packer-nvim/ ~/.local/share/nvim/site/pack/packer.nvim/opt/packer.nvim
```

In nvim run command `:Plugins`.
