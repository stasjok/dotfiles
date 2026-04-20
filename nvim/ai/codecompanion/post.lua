local config = require("codecompanion.config")
local log = require("codecompanion.utils.log")
local utils = require("codecompanion.utils")
local codecompanion = require("codecompanion")

--- Add a file to the current chat by its path
---@param path string Path to the file
local function add_file_to_chat(path)
  -- Get the current chat
  local chat = codecompanion.last_chat()
  if not chat then
    chat = codecompanion.chat()

    if not chat then
      return log:warn("Could not create chat buffer")
    end
  end

  -- Format file for LLM
  local content, id, relative_path =
    require("codecompanion.interactions.chat.helpers").format_file_for_llm(path)

  -- Add message to chat
  chat:add_message({
    role = config.constants.USER_ROLE,
    content = content or "",
  }, {
    visible = false,
    context = { id = id, path = path },
    _meta = { tag = "file" },
  })

  -- Add to chat context
  chat.context:add({
    id = id or "",
    path = path,
    source = "codecompanion.interactions.chat.slash_commands.builtin.file",
  })

  utils.notify(
    string.format("Added the `%s` file to the chat", vim.fn.fnamemodify(relative_path, ":t"))
  )
end

--- Open Telescope picker for a directory
---@param directory string Directory to search in
local function open_file_picker(directory)
  local telescope = require("telescope.builtin")

  -- Open Telescope find_files
  telescope.find_files({
    prompt_title = "Select file(s)",
    cwd = directory,
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
          add_file_to_chat(selection.path)
        end
      end)

      return true
    end,
  })
end

--- Add file or open picker if a directory
---@param opts vim.api.keyset.create_user_command.command_args
local function add_files(opts)
  local path = vim.fs.normalize(opts.args)

  local stat = vim.uv.fs_stat(path)
  if not stat then
    return utils.notify("Path not found: " .. path, vim.log.levels.WARN)
  end

  path = vim.fs.abspath(opts.args)

  if stat.type == "directory" then
    open_file_picker(path)
  else
    add_file_to_chat(path)
  end
end

-- A user command for adding files to CodeCompanion chat
vim.api.nvim_create_user_command("CodeCompanionAddFile", add_files, {
  nargs = 1,
  complete = "file",
  desc = "Add file to CodeCompanion chat or pick from the directory",
})
