local buf_map = require("map").buf_map

local utils = {}

function utils.on_attach(client, bufnr)
  -- Mappings
  for lhs, rhs in pairs({
    ["gd"] = '<Cmd>lua require("telescope.builtin").lsp_definitions()<CR>',
    ["gD"] = "<Cmd>lua vim.lsp.buf.declaration()<CR>",
    ["<Leader>T"] = "<Cmd>lua vim.lsp.buf.type_definition()<CR>",
    ["<Leader>i"] = '<Cmd>lua require("telescope.builtin").lsp_implementations()<CR>',
    ["gr"] = '<Cmd>lua require("telescope.builtin").lsp_references()<CR>',
    ["gs"] = '<Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>',
    ["gS"] = '<Cmd>lua require("telescope.builtin").lsp_workspace_symbols()<CR>',
    ["<Leader>r"] = "<Cmd>lua vim.lsp.buf.rename()<CR>",
    ["K"] = "<Cmd>lua vim.lsp.buf.hover()<CR>",
    ["<Leader>a"] = "<Cmd>lua vim.lsp.buf.code_action()<CR>",
    ["<Leader>d"] = '<Cmd>lua require("telescope.builtin").lsp_document_diagnostics()<CR>',
    ["<Leader>D"] = '<Cmd>lua require("telescope.builtin").lsp_workspace_diagnostics()<CR>',
    ["]d"] = "<Cmd>lua vim.diagnostic.goto_next()<CR>",
    ["[d"] = "<Cmd>lua vim.diagnostic.goto_prev()<CR>",
    ["<Leader>F"] = "<Cmd>lua vim.lsp.buf.formatting()<CR>",
  }) do
    buf_map("n", lhs, rhs)
  end
  buf_map("x", "<Leader>F", ":lua vim.lsp.buf.range_formatting()<CR>")

  -- Show diagnostics automatically
  vim.cmd([[
augroup ShowDiagnostics
  autocmd! * <buffer>
  autocmd CursorHold,CursorHoldI <buffer> lua require("plugins.lspconfig.utils").show_diagnostics()
augroup END]])

  -- Document highlight
  if client.supports_method("textDocument/documentHighlight") then
    vim.cmd([[
augroup DocumentHighlight
  autocmd! * <buffer>
  autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
  autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
  autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
augroup END]])
  end

  -- Signature help
  require("lsp_signature").on_attach({
    hint_enable = false,
    floating_window_above_first = true,
    hi_parameter = "LspReferenceRead",
  })
end

function utils.show_diagnostics()
  local status, existing_float = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_preview")
  if status and vim.api.nvim_win_is_valid(existing_float) then
  else
    vim.diagnostic.open_float()
  end
end

local completion_kind_icons = {
  Class = "",
  Color = "",
  Constant = "",
  Constructor = "",
  EnumMember = "",
  Enum = "",
  Event = "",
  Field = "",
  File = "",
  Folder = "",
  Function = "",
  Interface = "",
  Keyword = "",
  Method = "ƒ",
  Module = "",
  Operator = "",
  Property = "",
  Reference = "",
  Snippet = "﬌",
  Struct = "",
  Text = "",
  TypeParameter = "",
  Unit = "",
  Value = "",
  Variable = "",
}

utils.completion_kinds = {}
-- Prepend icon to completion kind
for kind, icon in pairs(completion_kind_icons) do
  utils.completion_kinds[kind] = string.format("%s %s", icon, kind)
end

return utils
