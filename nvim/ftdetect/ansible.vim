autocmd BufRead,BufNewFile *ansible*/*.{yml,yaml},*/infrastructure/*.{yml,yaml} setlocal filetype=yaml.ansible
autocmd BufRead,BufNewFile *ansible*/*{production,qa,testing} setlocal filetype=ansible_hosts
