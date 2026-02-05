---@diagnostic disable: undefined-global

-- Do nothing for null-ls
if client.name == "null-ls" then
  return
end

-- Show diagnostics automatically
vim.api.nvim_create_autocmd("CursorHold", {
  desc = "Show diagnostics",
  group = require("utils").create_augroup("diagnostics", { buffer = bufnr }),
  buffer = bufnr,
  callback = function()
    local status, existing_float = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_preview")
    if status and vim.api.nvim_win_is_valid(existing_float) then
    else
      vim.diagnostic.open_float()
    end
  end,
})
