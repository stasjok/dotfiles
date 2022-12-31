{lib, ...}: {
  # I manage nix registry manually on my dev PC
  nix.registry = lib.mkForce {};
}
