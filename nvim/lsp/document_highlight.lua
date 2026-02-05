local utils = require("utils")
local api = vim.api
local lsp = vim.lsp
local uv = vim.uv
local buf_lsp = lsp.buf

-- Time to wait before sending a textDocument/documentHighlight request to the server
local debounce_timer = 300
-- First letters of modes to disable document highlights
local ignored_modes = { "v", "V", "", "s", "S", "" }

-- Autocommand groups
local augroup = api.nvim_create_augroup("buf_lsp_document_highlight_configuration", {})
local hl_augroup = api.nvim_create_augroup("lsp_document_highlight", { clear = false })

-- Namespace name for document highlights
local ns_name = "vim_lsp_references"

-- Timers for document highlights
---@type {[buffer]: uv_timer_t}
local timers = {}

-- LSP document highlight configurations
local function on_attach(args)
  local buf = args.buf
  local client = lsp.get_client_by_id(args.data.client_id)

  if client.supports_method("textDocument/documentHighlight") then
    timers[buf] = uv.new_timer()

    -- Cancel all pending requests. Make sure to unset it after calling.
    ---@type function?
    local cancel_requests

    local changetick = api.nvim_buf_get_changedtick(buf)

    -- Check if the cursor still on top of a highlight
    local function is_in_hl()
      local ns = api.nvim_create_namespace(ns_name)
      local row, col = utils.get_cursor_0(0)
      local line_extmarks = api.nvim_buf_get_extmarks(buf, ns, { row, 0 }, { row, -1 }, {
        details = true,
        type = "highlight",
      })
      return vim.iter(line_extmarks):any(function(extmark)
        return col >= extmark[3] and (col <= extmark[4].end_col or extmark[4].end_row > row)
      end)
    end

    -- Request document highlights
    local document_highlight_callback = vim.schedule_wrap(function()
      -- Make sure to make requests only in relevant buffer
      if api.nvim_get_current_buf() ~= buf then
        return
      end
      _, cancel_requests = lsp.buf_request(
        buf,
        "textDocument/documentHighlight",
        lsp.util.make_position_params(0, client.offset_encoding),
        function(...)
          -- cancel_requests is nil if request was cancelled
          if cancel_requests then
            cancel_requests = nil
            lsp.handlers["textDocument/documentHighlight"](...)
          end
        end
      )
    end)

    -- Refresh document highlights with debounce
    local function document_highlight()
      -- Clear document highlights at once
      buf_lsp.clear_references()

      -- Stop pending requests
      if cancel_requests then
        cancel_requests()
        cancel_requests = nil
      end

      -- Schedule document highlights
      timers[buf]:start(debounce_timer, 0, document_highlight_callback)
    end

    -- Enable document highlights immediately after LspAttach event
    document_highlight()

    -- Define autocommands
    api.nvim_clear_autocmds({ group = hl_augroup, buffer = buf })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      desc = "Update document highlights",
      group = hl_augroup,
      buffer = buf,
      callback = function()
        -- Stop timer
        timers[buf]:stop()

        -- Do nothing in ignored modes
        local mode = api.nvim_get_mode().mode:sub(1, 1)
        if vim.list_contains(ignored_modes, mode) then
          return
        end

        -- Refresh document highlights when buffer is changed
        -- or cursor has been moved from active highlight
        local new_changetick = api.nvim_buf_get_changedtick(buf)
        if changetick ~= new_changetick or not is_in_hl() then
          changetick = new_changetick

          document_highlight()
        end
      end,
    })
    api.nvim_create_autocmd("ModeChanged", {
      desc = "Clear document highlights",
      group = hl_augroup,
      buffer = buf,
      ---@diagnostic disable-next-line: redefined-local
      callback = function()
        -- Stop timer
        timers[buf]:stop()

        -- Get the first letter of the mode
        local mode = api.nvim_get_mode().mode:sub(1, 1)

        -- Clear document highlights when changing TO ignored_modes,
        if vim.list_contains(ignored_modes, mode) then
          buf_lsp.clear_references()
        -- Otherwise refresh document highlights if it's not already active
        elseif not is_in_hl() then
          document_highlight()
        end
      end,
    })
    api.nvim_create_autocmd({ "BufLeave" }, {
      desc = "Clear document highlights",
      group = hl_augroup,
      buffer = buf,
      callback = function()
        -- Stop timer
        timers[buf]:stop()

        buf_lsp.clear_references()
      end,
    })
  end
end

-- Remove buffer LSP document highlight configuration
local function on_detach(args)
  local buf = args.buf

  -- Disable document highlights
  if timers[buf] then
    timers[buf]:stop()
    timers[buf] = nil
  end
  buf_lsp.clear_references()
  api.nvim_clear_autocmds({ group = hl_augroup, buffer = buf })
end

-- Autocommands
api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  desc = "Configure LSP document highlights for a buffer",
  callback = on_attach,
})
api.nvim_create_autocmd("LspDetach", {
  group = augroup,
  desc = "Disable LSP document highlight configuration for a buffer",
  callback = on_detach,
})
