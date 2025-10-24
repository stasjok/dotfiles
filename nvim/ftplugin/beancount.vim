if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setlocal shiftwidth=2

setlocal commentstring=;\ %s
setlocal comments=:;

setlocal iskeyword=@,48-57,_,192-255,:,-,.

let b:undo_ftplugin = "setlocal shiftwidth< commentstring< comments< iskeyword<"
