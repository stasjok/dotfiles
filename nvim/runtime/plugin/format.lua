local buf_get_option = vim.api.nvim_buf_get_option
local map = vim.keymap.set
local buf_format = vim.lsp.buf.format
local fs_stat = vim.loop.fs_stat
local create_augroup = vim.api.nvim_create_augroup
local create_autocmd = vim.api.nvim_create_autocmd
local clear_autocmds = vim.api.nvim_clear_autocmds

---@class FormatConditionArgs
---@field buf integer Current buffer number
---@field client table LSP client object

---@class FormatFiletypeSettings
---@field server string? Language server name to use for formatting
---@field on_save boolean | fun(args: FormatConditionArgs): boolean | nil Whether to enable format on save
---@field override_document_formatting boolean? Override documentFormattingProvider capability
---@field override_document_range_formatting boolean? Override documentRangeFormattingProvider capability

---Format settings
---@type { [string]: FormatFiletypeSettings }
local settings = {
  lua = {
    server = "null-ls",
    ---@param args FormatConditionArgs
    ---@return boolean
    on_save = function(args)
      return args.client.config.root_dir
        and (
          fs_stat(args.client.config.root_dir .. "/stylua.toml") ~= nil
          or fs_stat(args.client.config.root_dir .. "/.stylua.toml") ~= nil
          or fs_stat(args.client.config.root_dir .. "/.styluaignore") ~= nil
        )
    end,
  },
  nix = {
    on_save = true,
  },
  yaml = {
    server = "yamlls",
    override_document_formatting = true,
  },
  toml = {
    on_save = true,
  },
  fish = {
    on_save = true,
  },
  markdown = {
    server = "null-ls",
    on_save = true,
  },
  go = {
    on_save = true,
  },
  rust = {
    on_save = true,
  },
  hcl = {
    on_save = true,
  },
}

---Returns a function for formatting with specific client id
---@param client_id integer The id of the client
---@return function
local function format_with_client_id(client_id)
  return function()
    buf_format({ id = client_id })
  end
end

---@class AutocmdCallbackArgument
---@field id integer The autocmd ID
---@field event string The name of the event that triggered the autocmd
---@field group integer? The autocmd group ID if it exists
---@field match string The match for which this autocmd was executed
---@field buf integer Currently effective buffer number
---@field file string File name of the buffer

---@class LspAttachCallbackArgument: AutocmdCallbackArgument
---@field data { client_id: integer }

---An autocmd callback for configuring format
---@param args LspAttachCallbackArgument
local function configure_format(args)
  local ft = buf_get_option(args.buf, "filetype")
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  -- Don't do anything if server is not matched
  if settings[ft] and settings[ft].server and client.name ~= settings[ft].server then
    return
  end

  -- Override capabilities
  if settings[ft] and settings[ft].override_document_formatting then
    client.server_capabilities.documentFormattingProvider = true
  end
  if settings[ft] and settings[ft].override_document_range_formatting then
    client.server_capabilities.documentRangeFormattingProvider = true
  end

  local format_fun = format_with_client_id(client.id)

  if client.server_capabilities.documentFormattingProvider then
    -- Mappings
    map("n", "<Leader>F", format_fun, { buffer = args.buf })

    -- Format on save
    if settings[ft] then
      if
        settings[ft].on_save == true
        or vim.is_callable(settings[ft].on_save)
          and settings[ft].on_save({
            buf = args.buf,
            client = client,
          })
      then
        local format_on_save_augroup = create_augroup("FormatOnSave", { clear = false })
        clear_autocmds({ group = format_on_save_augroup, buffer = args.buf })
        create_autocmd("BufWritePre", {
          desc = "Format on save",
          group = format_on_save_augroup,
          buffer = args.buf,
          callback = format_fun,
        })
      end
    end
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    -- Mappings
    map("x", "<Leader>F", format_fun, { buffer = args.buf })
  end
end

-- Configure format on LspAttach event
local format_augroup = create_augroup("FormatConfiguration", { clear = true })
create_autocmd("LspAttach", {
  group = format_augroup,
  callback = configure_format,
})
