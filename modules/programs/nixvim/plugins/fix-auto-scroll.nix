{ lib, ... }:
lib.nixvim.plugins.mkNeovimPlugin {
  name = "fix-auto-scroll";
  package = "fix-auto-scroll-nvim";
  description = "A plugin that restores a last screen view when switching buffers.";
  maintainers = [ lib.maintainers.stasjok ];
}
