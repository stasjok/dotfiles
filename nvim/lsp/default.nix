{ myLib, ... }:
{
  # LspAttach callback
  lsp.onAttach = myLib.readWrapDo ./on_attach.lua;

  # documentHighlight handling
  extraConfigLua = myLib.readWrapDo ./document_highlight.lua;

  imports = [
    ./inlay_hints.nix
    ./keymaps.nix
    ./none-ls.nix
    ./otter.nix
    ./servers
  ];
}
