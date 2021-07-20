" This ftplugin provides syntax highlighting for blocks of code surrounded
" with "source" or "syntaxhighlight" tags. These tags are used by the GeSHi
" mediawiki extension:
" https://www.mediawiki.org/wiki/Extension:SyntaxHighlight_GeSHi
"
" By default, only languages present in the current buffer are highlighted.
" You can customize this behavior by defining a few variables in your .vimrc:
"
"   g:loaded_mediawiki_filetype_highlighting
"       If set, highlighting in the "source" and "syntaxhighlight" tags will be
"       disabled.
"       Example:
"           let g:loaded_mediawiki_filetype_highlighting = 1
"       Default: unset
"
"   g:mediawiki_forced_wikilang
"       List of GeSHi languages for which highlighting should always be
"       loaded, even if there is no corresponding tag in the current buffer.
"       Example:
"           let g:mediawiki_forced_wikilang = ['sql', 'java', 'java5']
"       Default: []
"       Note: Forcing many languages can slow down the opening of mediawiki
"       files. If you often use various languages, it may be better to keep
"       the default values, and reload the buffer from time to time with :e
"
"   g:mediawiki_ignored_wikilang
"       List of GeSHi languages for which no syntax highlighting is desired.
"       If a language is both forced and ignored, it will be ignored.
"       Example:
"           let g:mediawiki_ignored_wikilang = ['html4strict', 'html5']
"       Default: []
"
"   g:mediawiki_wikilang_to_vim_overrides
"       Dictionary allowing to overrides the default language mappings.
"       The key of the dictionary is a GeSHi language, and the value is a Vim
"       filetype.
"       Example:
"           let g:mediawiki_wikilang_to_vim_overrides = {
"                   \ 'bash': 'zsh',
"                   \ 'new_geshi_language': 'foobar',
"                   \ }
"       Default: {}

" Many MediaWiki wikis prefer line breaks only at the end of paragraphs
" (like in a text processor), which results in long, wrapping lines.
setlocal wrap linebreak
setlocal textwidth=0

" Make navigation more amenable to the long wrapping lines.
noremap <buffer> k gk
noremap <buffer> j gj
noremap <buffer> <Up> gk
noremap <buffer> <Down> gj
noremap <buffer> 0 g0
noremap <buffer> ^ g^
noremap <buffer> $ g$
" noremap <buffer> D dg$
" noremap <buffer> C cg$
" noremap <buffer> A g$a
inoremap <buffer> <Up> <C-O>gk
inoremap <buffer> <Down> <C-O>gj

setlocal matchpairs+=<:>

" match HTML tags (taken directly from $VIM/ftplugin/html.vim)
" HTML:  thanks to Johannes Zellner and Benji Fisher.
if exists("loaded_matchit")
    let b:match_ignorecase = 1
    let b:match_words = '<:>,' .
    \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
    \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
    \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'
endif

" Enable folding based on ==sections==
setlocal foldexpr=getline(v:lnum)=~'^\\(=\\+\\)[^=]\\+\\1\\(\\s*<!--.*-->\\)\\=\\s*$'?\">\".(len(matchstr(getline(v:lnum),'^=\\+'))-1):\"=\"
setlocal fdm=expr

" Treat lists, indented text and tables as comment lines and continue with the
" same formatting in the next line (i.e. insert the comment leader) when hitting
" <CR> or using "o".
setlocal comments=n:#,n:*,n:\:
setlocal formatoptions+=ro

if exists('g:loaded_mediawiki_filetype_highlighting')
    finish
endif
let g:loaded_mediawiki_filetype_highlighting = 1

" Set default values
if !exists('g:mediawiki_ignored_wikilang')
    let g:mediawiki_ignored_wikilang = []
endif
if !exists('g:mediawiki_forced_wikilang')
    let g:mediawiki_forced_wikilang = []
endif
if !exists('g:mediawiki_wikilang_to_vim_overrides')
    let g:mediawiki_wikilang_to_vim_overrides = {}
endif

augroup MediaWiki
    autocmd!
    autocmd Syntax mediawiki call mediawiki#PerformHighlighting()
    " To fix highlighting of syntaxhighlight tag
    " In order for this rules have higher priority
    " they need to be loaded later
    autocmd Syntax mediawiki syntax match wikiSourceTag /<source\s\+[^>]\+/ contained contains=htmlTag
    autocmd Syntax mediawiki syntax match wikiSourceEndTag /<\/source>/ contained contains=htmlEndTag
    autocmd Syntax mediawiki syntax match wikiSyntaxHLTag /<syntaxhighlight\s\+[^>]\+>/ contained contains=htmlTag
    autocmd Syntax mediawiki syntax match wikiSyntaxHLEndTag /<\/syntaxhighlight>/ contained contains=htmlEndTag
augroup END

