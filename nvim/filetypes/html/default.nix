{ myLib, ... }: {
  extraFiles = myLib.mkExtraFiles' ./queries "queries/html" [
    ./queries/highlights.scm
  ];
}
