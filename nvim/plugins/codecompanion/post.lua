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

  local telescope = require("telescope.builtin")

  -- Get absolute directory path
  local target_dir = vim.fn.fnamemodify(directory, ":p")

  -- Open Telescope find_files
  telescope.find_files({
    prompt_title = opts.title or "Select file(s) from: " .. vim.fn.fnamemodify(target_dir, ":t"),
    cwd = target_dir,
    hidden = opts.hidden or true,
    attach_mappings = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Replace the default action with our custom handler
      actions.select_default:replace(function(bufnr, _)
        local picker = action_state.get_current_picker(bufnr)
        local selections = picker:get_multi_selection()

        if vim.tbl_isempty(selections) then
          selections = { action_state.get_selected_entry() }
        end

        actions.close(bufnr)

        for _, selection in ipairs(selections) do
          add_file_to_chat(selection.path, { silent = opts.silent })
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

-- A user command for adding files to CodeCompanion chat
vim.api.nvim_create_user_command("CodeCompanionAddFile", function(opts)
  local input = opts.args
  add_or_pick(input)
end, {
  nargs = "?",
  complete = "file",
  desc = "Add file to CodeCompanion chat or pick from the directory",
})
