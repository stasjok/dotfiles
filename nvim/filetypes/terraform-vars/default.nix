{
  extraFiles = {
    # Ftplugin
    "ftplugin/terraform-vars.vim".text = builtins.readFile ./ftplugin.vim;
    # Indent
    "indent/terraform-vars.vim".text = builtins.readFile ./indent.vim;
  };
}
