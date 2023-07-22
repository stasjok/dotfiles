{fetchurl}: final: prev: {
  yaml-language-server = prev.yaml-language-server.override (prevArgs: {
    # Add prettier version <3.0.0
    dependencies = let
      prettier = {
        name = "prettier";
        packageName = "prettier";
        version = "2.8.8";
        src = fetchurl {
          url = "https://registry.npmjs.org/prettier/-/prettier-2.8.8.tgz";
          sha512 = "tdN8qQGvNjw4CHbY+XXk0JgCXn9QiF21a55rBe5LJAU+kDyC4WQn4+awm2Xfk2lQMk5fKup9XgzTZtGkjBdP9Q==";
        };
      };
    in
      prevArgs.dependencies ++ [prettier];
    # Disable original nixpkgs overrides
    nativeBuildInputs = [];
    postInstall = "";
  });
}
