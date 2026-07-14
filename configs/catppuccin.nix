{ inputs, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "macchiato";

    # Replace palette source because IFD is allowed from flake inputs
    sources.palette = inputs.catppuccin-palette;

    # Warning: the option `programs.gemini-cli' has been renamed to `programs.antigravity-cli'.
    gemini-cli.enable = false;

    # Disable modules with IFD
    mako.enable = false;
  };
}
