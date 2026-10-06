---@param opts vim.api.keyset.create_user_command.command_args
local function add_files(opts)
  local codecompanion = require("codecompanion")
  local config = require("codecompanion.config")
  local File = require("codecompanion.interactions.shared.slash_commands.file")
  local SlashCommands = require("codecompanion.interactions.chat.slash_commands")
  local log = require("codecompanion.utils.log")
  local utils = require("codecompanion.utils")

  local path = vim.fs.normalize(opts.args)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return utils.notify("Path not found: " .. path, vim.log.levels.WARN)
  end
  path = vim.fs.abspath(opts.args)

  local chat = codecompanion.last_chat()
  if not chat then
    chat = codecompanion.chat()

    if not chat then
      return log:warn("Could not create chat buffer")
    end
  end

  -- Copy the /file slash command config and point its search dirs at the containing directory.
  -- `dirs` is only read by the picker, so it only matters on the directory branch.
  ---@diagnostic disable-next-line: undefined-field
  local file_config = vim.deepcopy(config.interactions.chat.slash_commands["file"]) --[[@as table]]
  file_config.opts.dirs = { path }

  local file = File.new({ Chat = chat, config = file_config, context = {}, opts = {} })

  -- Directories open the picker (execute); files attach directly (output).
  if stat.type == "directory" then
    file:execute(SlashCommands)
  else
    file:output({
      path = path,
      relative_path = vim.fn.fnamemodify(path, ":."),
    })
  end
end

-- A user command for adding files to CodeCompanion chat
vim.api.nvim_create_user_command("CodeCompanionAddFile", add_files, {
  nargs = 1,
  complete = "file",
  desc = "Add file to CodeCompanion chat or pick from the directory",
})
