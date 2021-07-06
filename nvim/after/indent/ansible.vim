" Use indentkeys from YAML indent
setlocal indentkeys=!^F,o,O,0#,0},0],<:>,0-
" Use extended indentexpr function
setlocal indentexpr=GetYAMLAnsibleIndent(v:lnum)

" Only define the function once.
if exists('*GetYAMLAnsibleIndent')
    finish
endif

" From indent/ansible.vim
let s:prev_task_regex = '\v^\s*-\s*(name|hosts|role):'

" From indent/yaml.vim
function s:FindPrevLessIndentedLine(lnum, ...)
    let prevlnum = prevnonblank(a:lnum-1)
    let curindent = a:0 ? a:1 : indent(a:lnum)
    while           prevlnum
                \&&  indent(prevlnum) >=  curindent
                \&& getline(prevlnum) =~# '^\s*#'
        let prevlnum = prevnonblank(prevlnum-1)
    endwhile
    return prevlnum
endfunction

function s:FindPrevLEIndentedLineMatchingRegex(lnum, regex)
    let plilnum = s:FindPrevLessIndentedLine(a:lnum, indent(a:lnum)+1)
    while plilnum && getline(plilnum) !~# a:regex
        let plilnum = s:FindPrevLessIndentedLine(plilnum)
    endwhile
    return plilnum
endfunction

" Extend GetYAMLIndent to support g:ansible_unindent_after_newline
function GetYAMLAnsibleIndent(lnum)
    if a:lnum == 1 || !prevnonblank(a:lnum-1)
        return 0
    endif

    if exists("g:ansible_unindent_after_newline")
        if (a:lnum-1) != prevnonblank(a:lnum-1)
            let plilmr = s:FindPrevLEIndentedLineMatchingRegex(a:lnum-1,
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
        return GetYAMLIndent(a:lnum)
    endif
endfunction
