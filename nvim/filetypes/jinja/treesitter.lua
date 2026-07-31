vim.api.nvim_create_autocmd("FileType", {
  pattern = { "*.jinja", "jinja.*" },
  group = vim.api.nvim_create_augroup("jinja_treesitter", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local filetype = args.match
    local embedded_filetype = filetype:match("^(.+)%.jinja$") or filetype:match("^jinja%.(.+)$")
    local embedded_lang = embedded_filetype and vim.treesitter.language.get_lang(embedded_filetype)
    local has_embedded_parser = embedded_lang and vim.treesitter.language.add(embedded_lang)
    if embedded_filetype and embedded_lang and has_embedded_parser then
      local compound_lang = "jinja_with_" .. embedded_filetype:gsub("[^%w_]", "_")
      vim.treesitter.language.add(compound_lang, {
        path = "__JINJA_PARSER_PATH__",
        symbol_name = "jinja",
      })

      -- A parser alias gives every compound filetype an independent query set.
      vim.treesitter.language.register(compound_lang, filetype)

      local injections = string.format(
        [[
;; inherits: jinja

((content) @injection.content
  (#set! injection.language "%s")
  (#set! injection.combined))
]],
        embedded_lang
      )

      if not vim.treesitter.query.get(compound_lang, "highlights") then
        vim.treesitter.query.set(compound_lang, "highlights", ";; inherits: jinja")
      end
      if not vim.treesitter.query.get(compound_lang, "injections") then
        vim.treesitter.query.set(compound_lang, "injections", injections)
      end
      vim.treesitter.start(buf)
    else
      -- Without an embedded parser, use the normal Jinja parser and syntax fallback.
      vim.treesitter.language.register("jinja", filetype)
      vim.treesitter.start(buf)
      vim.bo[buf].syntax = "ON"
    end

    local stop_treesitter = string.format("silent! lua vim.treesitter.stop(%d)", buf)
    local undo_ftplugin = vim.b[buf].undo_ftplugin
    vim.b[buf].undo_ftplugin = undo_ftplugin and (undo_ftplugin .. " | " .. stop_treesitter)
      or stop_treesitter
  end,
})
