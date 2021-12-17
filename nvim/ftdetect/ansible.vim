autocmd BufRead,BufNewFile *ansible*/*.{yml,yaml} set filetype=yaml.ansible
autocmd BufRead,BufNewFile *ansible*/*{production,qa,testing} set filetype=ansible_hosts
