vim.cmd([[
augroup NixAutoFormatting
autocmd! * <buffer>
autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
augroup END
]])
