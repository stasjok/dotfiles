{ config, ... }:
{
  # Reload patched modules compiled into Nvim binary
  extraConfigLuaPre = ''
    vim.fs = dofile("${config.build.nvimPackage.unwrapped}/share/nvim/runtime/lua/vim/fs.lua")
  '';
}
