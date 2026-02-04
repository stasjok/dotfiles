if exists('b:did_indent')
  finish
endif

" Load original YAML indent
runtime indent/yaml.vim

" Use extended indentexpr function
setlocal indentexpr=GetSaltIndent(v:lnum)

" Only define the function once.
if exists('*GetSaltIndent')
    finish
endif

" Extend GetYAMLIndent to reset indent after empty line
function GetSaltIndent(lnum)
    let prevlnum = prevnonblank(a:lnum-1)
    let prevline = getline(prevlnum)
    let previndent = indent(prevlnum)
    if (a:lnum-1) != prevlnum
        if prevline =~# '\v^\s+- \w+:\s+\S' " after '- key: value'
            return 0
        endif
    endif

    let listmapkeyregex='\v^\s*-\s+\#@!\S@=%(\''%([^'']|\''\'')*\'''.
                \                         '|\"%([^"\\]|\\.)*\"'.
                \                         '|%(%(\:\ )@!.)*)\:'.
                \         '%(\ [|>][+\-]?|)'.
                \         '%(\s+\#.*|\s*)$'
    let jinjablockregex='^\s*{%.\+%}\s*$'
    if prevline =~# '\v^\s*-$'
        " -
        "   |
        return previndent+shiftwidth()
    elseif prevline =~# listmapkeyregex
        " - something:
        "     |
        return shiftwidth() == 2 ? previndent+shiftwidth()*2 : previndent+shiftwidth()
    elseif prevline =~# jinjablockregex
        " don't do anything after {% jinja %}
        return -1
    else
        return GetYAMLIndent(a:lnum)
    endif
endfunction
