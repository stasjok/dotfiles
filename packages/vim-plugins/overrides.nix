{}: final: prev: {
  # Remove bundled luassert, add it as dependency instead
  plenary-nvim = prev.plenary-nvim.overrideAttrs (_: {
    prePatch = ''
      rm -r lua/luassert
    '';
    dependencies = with final; [luassert];
  });
}
