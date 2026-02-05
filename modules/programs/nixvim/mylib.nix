{ lib, ... }:
{
  _module.args.myLib = {
    readWrapDo = file: lib.nixvim.wrapDo (builtins.readFile file);
  };
}
