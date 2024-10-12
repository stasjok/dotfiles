{
  callPackage,
  lib,
}:
final: prev:
let
  # Lua packages
  packageOverrides = callPackage ../lua-packages { };

  # Lua interpreter overrides
  interpreterOverrides =
    {
    };

  mapAttrsFn =
    name: drv:
    let
      overrides = {
        inherit packageOverrides;
      } // lib.attrByPath [ name ] { } interpreterOverrides // { self = builtins.getAttr name final; };
    in
    if drv ? override then drv.override overrides else drv;
in
builtins.mapAttrs mapAttrsFn prev
