local chat_helpers = require("codecompanion.interactions.chat.helpers")
local config = require("codecompanion.config")
local log = require("codecompanion.utils.log")
local utils = require("codecompanion.utils")
local fmt = string.format

---Add a file to the current chat by its path
---@param file_path string Path to the file
---@param opts? { description?: string, silent?: boolean }
local function add_file_to_chat(file_path, opts)
  opts = opts or {}

  -- Get absolute path
  local absolute_path = vim.fn.fnamemodify(file_path, ":p")
  local relative_path = vim.fn.fnamemodify(absolute_path, ":.")

  -- Get the current chat
  local chat = require("codecompanion").last_chat()
  if not chat then
    log:warn("No active chat found")
    return
  end

  -- Format file for LLM
  local content, id, rel_path_for_msg, _, _ = chat_helpers.format_file_for_llm(absolute_path, opts)

  -- Add message to chat
  chat:add_message({
    role = config.constants.USER_ROLE,
    content = content or "",
  }, {
    visible = false,
    context = { id = id, path = absolute_path },
    _meta = { tag = "file" },
  })

  -- Add to chat context
  chat.context:add({
    id = id or "",
    path = absolute_path,
    source = "my_codecompanion_utils.add_file_to_chat",
  })

  if not opts.silent then
    utils.notify(fmt("Added `%s` to the chat", vim.fn.fnamemodify(rel_path_for_msg, ":t")))
  end
end

---Open Telescope picker for a directory
---@param directory string Directory to search in
---@param opts? { title?: string, silent?: boolean, hidden?: boolean }
local function open_file_picker(directory, opts)
  opts = opts or {}

  -- Check if Telescope is available
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    log:warn("Telescope is not installed")
    return
  end

  -- Function to handle file selection
  local on_select = function(selection)
    if not selection then
      return
    end

    -- Extract the path from the selection
    local path = selection.value or selection.path or selection
    if type(path) == "table" then
      path = path.path or path.value
    end

    if not path then
      log:warn("No file selected")
      return
    end

    -- Add the file to chat
    add_file_to_chat(path, { silent = opts.silent })
  end

  -- Get absolute directory path
  local target_dir = vim.fn.fnamemodify(directory, ":p")

  -- Open Telescope find_files
  telescope.find_files({
    prompt_title = opts.title or "Select file from: " .. vim.fn.fnamemodify(target_dir, ":t"),
    cwd = target_dir,
    hidden = opts.hidden or true,
    attach_mappings = function(_, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Replace the default action with our custom handler
      map("i", "<CR>", function(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()

        if vim.tbl_isempty(selections) then
          selections = { action_state.get_selected_entry() }
        end

        actions.close(prompt_bufnr)

        for _, selection in ipairs(selections) do
          if selection then
            on_select(selection)
          end
        end
      end)

      return true
    end,
  })
end

---Unified function: Add file or open picker based on input
---@param input? string File path, directory, or empty
---@param opts? { silent?: boolean, hidden?: boolean }
local function add_or_pick(input, opts)
  opts = opts or {}

  -- If no input, open picker in current directory
  if not input or input == "" then
    return open_file_picker(vim.fn.getcwd(), {
      title = "Select file from current directory",
      silent = opts.silent,
      hidden = opts.hidden,
    })
  end

  -- Check if the input exists
  local stat = vim.loop.fs_stat(input)

  if not stat then
    log:warn("Path not found: " .. input)
    return
  end

  -- Handle based on type
  if stat.type == "directory" then
    -- Open picker for directory
    return open_file_picker(input, {
      title = "Select file from: " .. vim.fn.fnamemodify(input, ":t"),
      silent = opts.silent,
      hidden = opts.hidden,
    })
  else
    -- Add single file
    return add_file_to_chat(input, { silent = opts.silent })
  end
end

---Single user command that handles all cases
vim.api.nvim_create_user_command("AddToChat", function(opts)
  local input = opts.args
  add_or_pick(input)
end, {
  nargs = "?",
  complete = function(ArgLead, CmdLine, CursorPos)
    -- Provide file and directory completion
    return vim.fn.getcompletion(ArgLead, "file")
  end,
  desc = "Add file to chat (file: add directly, dir: open picker, empty: pick from cwd)",
})
