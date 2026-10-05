local M = {}

--- Get the ledger file path from the current buffer
---@return string? path
local function get_ledger_path()
  local bufname = vim.fs.normalize(vim.api.nvim_buf_get_name(0))

  -- Assume that the main beancount file is ledger.beancount
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

  local from = nil
  if node_type == "date" or node_type == "payee" or node_type == "narration" then
    from = string.format("%s=%s", node_type, text)
  elseif node_type == "tag" or node_type == "link" then
    from = string.format('"%s" in %ss', text:sub(2), node_type)
  elseif node_type == "account" then
    from = string.format('has_account("%s")', text)
  else
    return nil
  end
  return string.format("print from %s", from)
end

-- Window id for focus reuse
---@type integer?
local winid = nil

--- Print bean-query results for node under cursor
function M.print_references()
  local ledger_path = get_ledger_path()
  if not ledger_path then
    vim.notify("Could not determine main beancount file", vim.log.levels.INFO)
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

  -- Focus last window if it's valid
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
    return
  end

  local cmd = { "bean-query", ledger_path, query }

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
    local contents = { "```beancount", vim.trim(output), "```" }

    _, winid = vim.lsp.util.open_floating_preview(contents, "markdown", {
      focus_id = "beancount-references",
    })
  end)

  vim.system(cmd, { text = true }, on_exit)
end

return M
