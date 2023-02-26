local map = vim.keymap.set

local utils = {}

local function show_diagnostics()
  local status, existing_float = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_preview")
  if status and vim.api.nvim_win_is_valid(existing_float) then
  else
    vim.diagnostic.open_float()
  end
end

---Callback invoked when LSP client attaches to a buffer
---@param client integer LSP client ID
---@param bufnr integer Buffer number
function utils.on_attach(client, bufnr)
  local function buf_map(mode, lhs, rhs)
    map(mode, lhs, rhs, { buffer = bufnr })
  end

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
    ["<Leader>d"] = '<Cmd>lua require("telescope.builtin").diagnostics({bufnr = 0})<CR>',
    ["<Leader>D"] = '<Cmd>lua require("telescope.builtin").diagnostics()<CR>',
    ["]d"] = "<Cmd>lua vim.diagnostic.goto_next()<CR>",
    ["[d"] = "<Cmd>lua vim.diagnostic.goto_prev()<CR>",
  }) do
    buf_map("n", lhs, rhs)
  end

  -- Show diagnostics automatically
  local diagnostics_group = api.nvim_create_augroup("Diagnostics", { clear = false })
  api.nvim_clear_autocmds({ group = diagnostics_group, buffer = bufnr })
  api.nvim_create_autocmd("CursorHold", {
    desc = "Show diagnostics",
    group = diagnostics_group,
    buffer = bufnr,
    callback = show_diagnostics,
  })

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
