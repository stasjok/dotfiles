{callPackage}: final: prev: {
  foreign-env = callPackage ./foreign-env.nix {inherit (final) buildFishPlugin;};
}
