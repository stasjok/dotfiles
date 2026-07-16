{ modulesPath, ... }: {
  disabledModules = [
    /${modulesPath}/../plugins/by-name/treesitter
  ];
  imports = [
    ./treesitter
  ];
}
