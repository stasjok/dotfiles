{
  ftplugin.terraform-vars.content = /* lua */ ''
    vim.cmd("runtime! ftplugin/terraform.vim")
  '';

  # Indent
  extraFiles."indent/terraform-vars.vim".text = builtins.readFile ./indent.vim;
}
