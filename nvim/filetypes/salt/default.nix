{
  ftplugin.salt.opts = {
    shiftwidth = 2;
    commentstring = "# %s";
  };

  # Indent
  extraFiles."indent/salt.vim".text = builtins.readFile ./indent.vim;
}
