{ lib, ... }:
{
  # LspAttach callback
  lsp.onAttach = lib.nixvim.wrapDo (builtins.readFile ./on_attach.lua);

  # documentHighlight handling
  extraConfigLua = lib.nixvim.wrapDo (builtins.readFile ./document_highlight.lua);

  imports = [
    ./inlay_hints.nix
    ./keymaps.nix
    ./none-ls.nix
    ./servers
  ];
}
