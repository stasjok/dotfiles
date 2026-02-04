{
  ftplugin.lua = {
    opts.shiftwidth = 2;

    content = /* lua */ ''
      vim.keymap.set({ "n", "x" }, "<LocalLeader>s", ":source<CR>", { buffer = true })
    '';
  };
}
