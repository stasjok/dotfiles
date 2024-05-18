{
  callPackage,
  lib,
}: final: prev: let
  # Lua packages
  packageOverrides = callPackage ../lua-packages {};

  # Lua interpreter overrides
  interpreterOverrides = {
    # luajit version matching neovim 0.10
    luajit_2_1 = {
      version = "2.1.1713484068";
      src = fetchTree {
        type = "github";
        owner = "LuaJIT";
        repo = "LuaJIT";
        rev = "75e92777988017fe47c5eb290998021bbf972d1f";
        narHash = "sha256-UnrsrXqAybmZve/Y86Q34Yn1TupNKm12wkJsfRpHoWw=";
      };
    };
  };

  mapAttrsFn = name: drv: let
    overrides =
      {inherit packageOverrides;}
      // lib.attrByPath [name] {} interpreterOverrides
      // {self = builtins.getAttr name final;};
  in
    if drv ? override
    then drv.override overrides
    else drv;
in
  builtins.mapAttrs mapAttrsFn prev
