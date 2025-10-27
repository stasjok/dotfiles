if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setlocal shiftwidth=2

setlocal commentstring=;\ %s
setlocal comments=:;

setlocal iskeyword=@,48-57,_,192-255,:,-,.,#,^ " '^' should be last

nnoremap <buffer> <LocalLeader>s <Cmd>Telescope beancount sections<CR>

let b:undo_ftplugin = "setlocal shiftwidth< commentstring< comments< iskeyword<"
let b:undo_ftplugin .= " | silent! nunmap <buffer> <LocalLeader>s"
