do
  -- Override default capabilities
  local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities()
  )

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.protocol.make_client_capabilities = function()
    return capabilities
  end
end
