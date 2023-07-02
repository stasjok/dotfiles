vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("buf_lsp_signature", {}),
  desc = "Attach lsp_signature plugin to a buffer",
  callback = function()
    require("lsp_signature").on_attach({
      hint_enable = false,
      floating_window_above_first = true,
      hi_parameter = "LspReferenceRead",
    })
  end,
})
