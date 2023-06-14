local utils = require("utils")
local map = vim.keymap.set
local api = vim.api
local lsp = vim.lsp.buf
local telescope_builtin = require("telescope.builtin")

local M = {}

local function show_diagnostics()
  local status, existing_float = pcall(api.nvim_buf_get_var, 0, "lsp_floating_preview")
  if status and api.nvim_win_is_valid(existing_float) then
  else
    vim.diagnostic.open_float()
  end
end

---Callback invoked when LSP client attaches to a buffer
---@param client integer LSP client ID
---@param bufnr integer Buffer number
function M.on_attach(client, bufnr)
  local function buf_map(mode, lhs, rhs)
    map(mode, lhs, rhs, { buffer = bufnr })
  end

  -- Mappings
  for lhs, rhs in pairs({
    ["gd"] = telescope_builtin.lsp_definitions,
    ["gD"] = lsp.declaration,
    ["<Leader>T"] = lsp.type_definition,
    ["<Leader>i"] = telescope_builtin.lsp_implementations,
    ["gr"] = telescope_builtin.lsp_references,
    ["gs"] = telescope_builtin.lsp_document_symbols,
    ["gS"] = telescope_builtin.lsp_workspace_symbols,
    ["<Leader>r"] = lsp.rename,
    ["K"] = lsp.hover,
    ["<Leader>a"] = lsp.code_action,
    ["<Leader>d"] = function()
      telescope_builtin.diagnostics({ bufnr = 0 })
    end,
    ["<Leader>D"] = telescope_builtin.diagnostics,
    ["]d"] = vim.diagnostic.goto_next,
    ["[d"] = vim.diagnostic.goto_prev,
  }) do
    buf_map("n", lhs, rhs)
  end

  -- Visual mappings
  for lhs, rhs in pairs({
    ["<Leader>a"] = lsp.code_action,
  }) do
    buf_map("x", lhs, rhs)
  end

  -- Show diagnostics automatically
  api.nvim_create_autocmd("CursorHold", {
    desc = "Show diagnostics",
    group = utils.create_augroup("Diagnostics", { buffer = bufnr }),
    buffer = bufnr,
    callback = show_diagnostics,
  })

  -- Document highlight
  if client.supports_method("textDocument/documentHighlight") then
    local hl_augroup = utils.create_augroup("DocumentHighlight", { buffer = bufnr })
    api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      desc = "Document highlights",
      group = hl_augroup,
      buffer = bufnr,
      callback = lsp.document_highlight,
    })
    api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      desc = "Remove document highlights",
      group = hl_augroup,
      buffer = bufnr,
      callback = lsp.clear_references,
    })
  end

  -- Signature help
  require("lsp_signature").on_attach({
    hint_enable = false,
    floating_window_above_first = true,
    hi_parameter = "LspReferenceRead",
  })
end

local completion_kind_icons = {
  Array = "",
  Boolean = "",
  Class = "󰊾",
  Color = "",
  Constant = "",
  Constructor = "",
  Enum = "󰕘",
  EnumMember = "󰕚",
  Event = "",
  Field = "",
  File = "󰈙",
  Folder = "󰝰",
  Function = "",
  Interface = "",
  Key = "󰌋",
  Keyword = "󰌈",
  Method = "󰡱",
  Module = "",
  Namespace = "",
  Null = "󰟢",
  Number = "󰎠",
  Object = "󰅩",
  Operator = "",
  Package = "",
  Property = "",
  Reference = "",
  Snippet = "󰘌",
  String = "",
  Struct = "",
  Text = "",
  TypeParameter = "󰊄",
  Unit = "",
  Value = "󱗽",
  Variable = "󰯍",
}

M.completion_kinds = {}
-- Prepend icon to completion kind
for kind, icon in pairs(completion_kind_icons) do
  M.completion_kinds[kind] = string.format("%s %s", icon, kind)
end

return M
