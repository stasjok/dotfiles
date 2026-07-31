vim.api.nvim_create_autocmd("FileType", {
  pattern = "*.jinja",
  group = vim.api.nvim_create_augroup("jinja_treesitter", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local filetype = args.match
    local embedded_filetype = filetype:match("^(.+)%.jinja$")
    local embedded_lang = embedded_filetype and vim.treesitter.language.get_lang(embedded_filetype)
    local has_embedded_parser = embedded_lang and vim.treesitter.language.add(embedded_lang)

    -- Make compound filetypes use Jinja as their root parser.
    vim.treesitter.language.register("jinja", filetype)

    if has_embedded_parser then
      vim.treesitter.query.set(
        "jinja",
        "injections",
        string.format(
          [[
((comment) @injection.content
  (#set! injection.language "comment"))

((inline) @injection.content
  (#set! injection.language "jinja_inline"))

((content) @injection.content
  (#set! injection.language "%s")
  (#set! injection.combined))
]],
          embedded_lang
        )
      )
    end

    vim.treesitter.start(buf, "jinja")

    if not has_embedded_parser then
      vim.bo[buf].syntax = "ON"
    end

    local stop_treesitter = string.format("silent! lua vim.treesitter.stop(%d)", buf)
    local undo_ftplugin = vim.b[buf].undo_ftplugin
    vim.b[buf].undo_ftplugin = undo_ftplugin and (undo_ftplugin .. " | " .. stop_treesitter)
      or stop_treesitter
  end,
})
