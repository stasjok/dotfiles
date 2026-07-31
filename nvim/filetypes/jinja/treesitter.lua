local jinja_parser_path = vim.api.nvim_get_runtime_file("parser/jinja.so", false)[1]

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*.jinja",
  group = vim.api.nvim_create_augroup("jinja_treesitter", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local filetype = args.match
    local embedded_filetype = filetype:match("^(.+)%.jinja$")
    local embedded_lang = embedded_filetype and vim.treesitter.language.get_lang(embedded_filetype)
    local has_embedded_parser = embedded_lang and vim.treesitter.language.add(embedded_lang)
    local compound_lang = "jinja_compound_" .. filetype:gsub("[^%w_]", "_")
    local has_jinja_parser = jinja_parser_path
      and vim.treesitter.language.add(compound_lang, {
        path = jinja_parser_path,
        symbol_name = "jinja",
      })

    if has_jinja_parser then
      -- A parser alias gives every compound filetype an independent query set.
      vim.treesitter.language.register(compound_lang, filetype)

      local injections = [[
((comment) @injection.content
  (#set! injection.language "comment"))

((inline) @injection.content
  (#set! injection.language "jinja_inline"))
]]

      if has_embedded_parser then
        injections = injections
          .. string.format(
            [[
((content) @injection.content
  (#set! injection.language "%s")
  (#set! injection.combined))
]],
            embedded_lang
          )
      end

      if not vim.treesitter.query.get(compound_lang, "highlights") then
        vim.treesitter.query.set(compound_lang, "highlights", ";; inherits: jinja")
      end
      if not vim.treesitter.query.get(compound_lang, "injections") then
        vim.treesitter.query.set(compound_lang, "injections", injections)
      end
      vim.treesitter.start(buf)
    end

    if not has_jinja_parser or not has_embedded_parser then
      vim.bo[buf].syntax = "ON"
    end

    local stop_treesitter = string.format("silent! lua vim.treesitter.stop(%d)", buf)
    local undo_ftplugin = vim.b[buf].undo_ftplugin
    vim.b[buf].undo_ftplugin = undo_ftplugin and (undo_ftplugin .. " | " .. stop_treesitter)
      or stop_treesitter
  end,
})
