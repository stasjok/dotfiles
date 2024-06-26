local utils = require("utils")
local vim = vim
local keymap_set = vim.keymap.set
local api = vim.api
local lsp = vim.lsp
local buf_lsp = lsp.buf
local inlay_hint = lsp.inlay_hint
local diagnostic = vim.diagnostic

local augroup = api.nvim_create_augroup("buf_lsp_configuration", {})

-- LSP buffer configurations
local function on_attach(args)
  local buf = args.buf
  local client = lsp.get_client_by_id(args.data.client_id)
  if not client then
    return
  end

  -- Do nothing for null-ls
  if client.name == "null-ls" then
    return
  end

  -- Mappings
  local function map(mode, lhs, rhs)
    keymap_set(mode, lhs, rhs, { buffer = buf })
  end
  local telescope_builtin = require("telescope.builtin")

  map("n", "gd", telescope_builtin.lsp_definitions)
  map("n", "gD", buf_lsp.declaration)
  map("n", "<Leader>T", telescope_builtin.lsp_type_definitions)
  map("n", "<Leader>i", telescope_builtin.lsp_implementations)
  map("n", "gr", telescope_builtin.lsp_references)
  map("n", "gs", telescope_builtin.lsp_document_symbols)
  map("n", "gS", telescope_builtin.lsp_workspace_symbols)
  map("n", "<Leader>r", buf_lsp.rename)
  map({ "n", "x" }, "<Leader>a", buf_lsp.code_action)
  map("n", "<Leader>d", function()
    telescope_builtin.diagnostics({ bufnr = 0 })
  end)
  map("n", "<Leader>D", telescope_builtin.diagnostics)

  -- Show diagnostics automatically
  api.nvim_create_autocmd("CursorHold", {
    desc = "Show diagnostics",
    group = utils.create_augroup("diagnostics", { buffer = buf }),
    buffer = buf,
    callback = function()
      local status, existing_float = pcall(api.nvim_buf_get_var, 0, "lsp_floating_preview")
      if status and api.nvim_win_is_valid(existing_float) then
      else
        diagnostic.open_float()
      end
    end,
  })
end

-- Autocommands
api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  desc = "Configure LSP for a buffer",
  callback = on_attach,
})

-- Inlay hints
inlay_hint.enable()
vim.keymap.set("n", "<Leader>I", function()
  inlay_hint.enable(not inlay_hint.is_enabled())
end)
vim.keymap.set({ "n", "x" }, "<Leader>bi", function()
  inlay_hint.enable(not inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end)
