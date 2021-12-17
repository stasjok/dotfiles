" Use indentkeys from YAML indent
setlocal indentkeys=!^F,o,O,0#,0},0],<:>,0-
" Use extended indentexpr function
setlocal indentexpr=GetYAMLAnsibleIndent(v:lnum)

" Only define the function once.
if exists('*GetYAMLAnsibleIndent')
    finish
endif

" From indent/ansible.vim
let s:prev_task_regex = '\v^\s*-\s+(name|hosts|role):'

function s:FindPrevLineMatchingRegex(lnum, regex)
    let plnum = prevnonblank(a:lnum-1)
    while plnum && getline(plnum) !~# a:regex
        let plnum = prevnonblank(plnum-1)
    endwhile
    return plnum
endfunction

" Extend GetAnsibleIndent to unindent to previous task
function GetYAMLAnsibleIndent(lnum)
    if a:lnum == 1 || !prevnonblank(a:lnum-1)
        return 0
    endif

    if exists("g:ansible_unindent_after_newline")
        if (a:lnum-1) != prevnonblank(a:lnum-1)
            let plilmr = s:FindPrevLineMatchingRegex(a:lnum,
                        \ s:prev_task_regex)
            if plilmr
                return indent(plilmr)
            else
                return 0
            endif
        endif
    endif

    let prevlnum = prevnonblank(a:lnum-1)
    let prevline = getline(prevlnum)
    let previndent = indent(prevlnum)
    let s:listmapkeyregex='\v^\s*-\s+\#@!\S@=%(\''%([^'']|\''\'')*\'''.
                \                         '|\"%([^"\\]|\\.)*\"'.
                \                         '|%(%(\:\ )@!.)*)\:'.
                \         '%(\ [|>][+\-]?|)'.
                \         '%(\s+\#.*|\s*)$'
    if prevline =~# '\v^\s*-$'
        " -
        "   |
        return previndent+shiftwidth()
    elseif prevline =~# s:listmapkeyregex
        " - something:
        "     |
        return shiftwidth() == 2 ? previndent+shiftwidth()*2 : previndent+shiftwidth()
    else
        return GetAnsibleIndent(a:lnum)
    endif
endfunction
