do
  local utils = require("utils")
  local api = vim.api
  local lsp = vim.lsp
  local buf_lsp = lsp.buf
  local diagnostic = vim.diagnostic

  local augroup = api.nvim_create_augroup("buf_lsp_configuration", {})

  -- LSP buffer configurations
  local function on_attach(args)
    local buf = args.buf
    local client = lsp.get_client_by_id(args.data.client_id)

    -- Do nothing for null-ls
    if client.name == "null-ls" then
      return
    end

    -- Mappings
    local keymap_set = vim.keymap.set
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
    map("n", "K", buf_lsp.hover)
    map({ "n", "x" }, "<Leader>a", buf_lsp.code_action)
    map("n", "<Leader>d", function()
      telescope_builtin.diagnostics({ bufnr = 0 })
    end)
    map("n", "<Leader>D", telescope_builtin.diagnostics)
    map("n", "]d", diagnostic.goto_next)
    map("n", "[d", diagnostic.goto_prev)

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

    -- Document highlight
    if client.supports_method("textDocument/documentHighlight") then
      local hl_augroup = utils.create_augroup("document_highlight", { buffer = buf })
      api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        desc = "Show document highlights",
        group = hl_augroup,
        buffer = buf,
        callback = buf_lsp.document_highlight,
      })
      api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        desc = "Remove document highlights",
        group = hl_augroup,
        buffer = buf,
        callback = buf_lsp.clear_references,
      })
    end

    -- Signature help
    require("lsp_signature").on_attach({
      hint_enable = false,
      floating_window_above_first = true,
      hi_parameter = "LspReferenceRead",
    })
  end

  -- Autocommands
  api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    desc = "Configure LSP for a buffer",
    callback = on_attach,
  })
end
