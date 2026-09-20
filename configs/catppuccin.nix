{ inputs, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "macchiato";

    # Replace palette source because IFD is allowed from flake inputs
    sources.palette = inputs.catppuccin-palette;

    # Disable modules with IFD
    mako.enable = false;
  };
}
