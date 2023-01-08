" TODO: Use vim.filetype in neovim 0.8
autocmd BufRead,BufNewFile *ansible*/*\(Taskfile\)\@<!.{yml,yaml},*/infrastructure/*\(Taskfile\)\@<!.{yml,yaml} setlocal filetype=yaml.ansible
autocmd BufRead,BufNewFile *ansible*/*{production,qa,testing} setlocal filetype=ansible_hosts
