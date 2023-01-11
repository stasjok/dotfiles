{}: final: prev: {
  nvim-treesitter = prev.nvim-treesitter.overrideAttrs (oldAttrs: {
    patches = [
      ./nvim-treesitter/reduce-injection-false-positives.patch
    ];
  });
}
