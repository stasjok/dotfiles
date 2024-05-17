{
  inputs,
  neovim-unwrapped,
}:
neovim-unwrapped.overrideAttrs {
  pname = "neovim-patched";
  src = inputs.neovim;
}
