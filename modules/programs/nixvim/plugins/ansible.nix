{ lib, ... }:
lib.nixvim.plugins.mkVimPlugin {
  name = "ansible";
  package = "ansible-vim";
  globalPrefix = "ansible_";
  description = "Vim plugin for syntax highlighting Ansible's common filetypes.";

  maintainers = [ lib.maintainers.stasjok ];
}
