{
  # Ensure correct window options are set
  ftplugin.help.content = /* lua */ ''
    vim.api.nvim_create_autocmd("BufWinEnter", {
      buffer = 0,
      group = require("utils").create_augroup("help_options", { buffer = 0, clear = true }),
      command = "setlocal scrolloff< sidescrolloff< signcolumn=auto nonumber norelativenumber nolist",
    })
  '';
}
