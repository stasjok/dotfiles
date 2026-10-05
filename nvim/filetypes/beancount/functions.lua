local M = {}

-- Store window id for focus reuse
---@type integer?
local last_winid = nil

--- Get the ledger file path from the current buffer
---@return string? path
local function get_ledger_path()
  local bufname = vim.api.nvim_buf_get_name(0)

  -- Find ledger.beancount file in parent directories
  local results = vim.fs.find("ledger.beancount", {
    upward = true,
    limit = 1,
    type = "file",
    path = vim.fs.dirname(bufname),
  })

  if #results > 0 then
    return results[1]
  end

  -- Fallback: use the buffer itself
  if bufname ~= "" then
    return bufname
  end

  return nil
end

--- Get bean-query command based on node type
---@param node TSNode
---@return string? query
local function get_bean_query(node)
  local node_type = node:type()
  local text = vim.treesitter.get_node_text(node, 0)

  if node_type == "date" then
    -- Query for entries on specific date
    return string.format("print from date=%s", text)
  elseif node_type == "account" then
    -- Query for account references
    return string.format('print from has_account("%s")', text)
  elseif node_type == "payee" then
    -- Query by payee name
    return string.format("print from payee=%s", text)
  elseif node_type == "narration" then
    -- Query by narration
    return string.format("print from narration=%s", text)
  elseif node_type == "tag" then
    -- Query for entries with specific tag (strip # prefix)
    local tag_name = text:sub(2)
    return string.format('print from "%s" in tags', tag_name)
  elseif node_type == "link" then
    -- Query for entries with specific link (strip ^ prefix)
    local link_name = text:sub(2)
    return string.format('print from "%s" in links', link_name)
  else
    -- Other nodes don't make sense for querying
    return nil
  end
end

--- Print bean-query results for node under cursor
function M.print_references()
  local ledger_path = get_ledger_path()
  if not ledger_path then
    vim.notify("Could not find ledger file", vim.log.levels.WARN)
    return
  end

  local node = vim.treesitter.get_node()
  if not node or not node:named() then
    vim.notify("No valid node under cursor", vim.log.levels.INFO)
    return
  end

  local query = get_bean_query(node)
  if not query then
    vim.notify("No query available for this node type", vim.log.levels.INFO)
    return
  end

  -- Check if window exists and is still valid
  if last_winid and vim.api.nvim_win_is_valid(last_winid) then
    -- Window exists, just focus it
    vim.api.nvim_set_current_win(last_winid)
    return
  end

  local cmd = { "bean-query", ledger_path, query }

  -- Run query asynchronously
  ---@param obj vim.SystemCompleted
  local on_exit = vim.schedule_wrap(function(obj)
    if obj.code ~= 0 then
      vim.notify("bean-query error: " .. (obj.stderr or ""), vim.log.levels.ERROR)
      return
    end

    local output = obj.stdout or ""

    if output == "" then
      vim.notify("No results found", vim.log.levels.INFO)
      return
    end

    -- Wrap in beancount code block for markdown syntax
    local lines_arr = { "```beancount", output, "```" }

    -- Create floating window using vim.lsp.util.open_floating_preview
    local config = {
      focus_id = "beancount-print-references",
    }

    _, last_winid = vim.lsp.util.open_floating_preview(lines_arr, "markdown", config)
  end)

  vim.system(cmd, { text = true }, on_exit)
end

return M
