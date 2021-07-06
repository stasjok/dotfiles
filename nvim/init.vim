scriptencoding utf-8

call plug#begin(stdpath('data') . '/plugged')

" Solarized 8: True Colors
Plug 'lifepillar/vim-solarized8'

" coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Jinja
Plug 'glench/vim-jinja2-syntax'

" Ansible
Plug 'pearofducks/ansible-vim'

" MediaWiki
Plug 'chikamichi/mediawiki.vim'

" Salt
Plug 'saltstack/salt-vim'

" Markdown
Plug 'plasticboy/vim-markdown'

" Go
Plug 'fatih/vim-go'

" TypeScript
Plug 'herringtondarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'

" Unimpaired
Plug 'tpope/vim-unimpaired'

" Surround.vim
Plug 'tpope/vim-surround'

" Repeat.vim
Plug 'tpope/vim-repeat'

" Auto Pairs
Plug 'jiangmiao/auto-pairs'

" Git
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" Comment
Plug 'tomtom/tcomment_vim'

" Align
Plug 'junegunn/vim-easy-align'

" Undo
Plug 'sjl/gundo.vim'

" Better Whitespace
Plug 'ntpeters/vim-better-whitespace'

" File icons
Plug 'ryanoasis/vim-devicons'

" Statusline
Plug 'itchyny/lightline.vim'

" Initialize plugin system
call plug#end()

" Solarized Dark theme
set termguicolors
set background=dark
colorscheme solarized8

" Statusline configuration
let g:lightline = {
            \ 'colorscheme': 'solarized',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste', 'keymap' ],
            \             [ 'gitbranch', 'filename_active', 'readonly', 'cocstatus' ],
            \           ],
            \   'right': [ [ 'lineinfo' ],
            \              [ 'percent' ],
            \              [ 'filetype' ],
            \            ],
            \ },
            \ 'inactive': {
            \   'left': [ [ 'filename_inactive', 'readonly', 'cocstatus' ],
            \           ],
            \   'right': [ [ 'lineinfo' ],
            \              [ 'percent' ],
            \              [ 'filetype' ],
            \            ],
            \ },
            \ 'component': {
            \   'keymap': '%k',
            \   'filename_active': '%{LightlineFilename(winwidth(0)-54)}',
            \   'filename_inactive': '%{LightlineFilename(winwidth(0)-36)}',
            \   'filetype': '%{&ft}',
            \   'lineinfo': '%3l:%-2v%<',
            \   'fugitive': "%{substitute(FugitiveStatusline(), '\v\[Git:(.*)]', '\\1', '')}"
            \ },
            \ 'component_function': {
            \   'mode': 'LightlineMode',
            \   'readonly': 'LightlineReadonly',
            \   'gitbranch': 'LightlineGitBranch',
            \   'cocstatus': 'coc#status',
            \ },
            \ 'component_expand': {
            \ },
            \ }

function! LightlineMode()
    return &filetype ==# 'fugitive' ? 'Fugitive' :
                \ &filetype ==# 'GV' ? 'GV' :
                \ &filetype ==# 'coc-explorer' ? 'CoC Explorer' :
                \ &filetype ==# 'gundo' ? 'Gundo' :
                \ lightline#mode()
endfunction

function! LightlineFilename(width)
    let current_file = expand('%')
    let filename = &filetype =~# '\v(coc-explorer|gundo)' ? '' :
                \ &filetype =~# '\v(fugitive|gitcommit)' ? fnamemodify(current_file, ':~:.') :
                \ current_file =~# '^term://' ? substitute(current_file, '^.\+:', '', '') :
                \ current_file =~# '^fugitive://' ? fnamemodify(substitute(current_file, '^fugitive://', '', ''), ':~:.') :
                \ strlen(current_file) <= a:width ? current_file :
                \ a:width > 14 ? substitute(current_file, '\v.*\ze.{'.a:width.'}$', '<', '') :
                \ substitute(pathshorten(current_file), '\v.*\ze.{'.a:width.'}$', '<', '')
    let modified = &modified ? '[+]' : ''
    return filename . modified
endfunction

function! LightlineReadonly()
    return &readonly && &filetype !~# '\v(help|fugitive|git|coc-explorer|gundo)' ? 'RO' : ''
endfunction

function LightlineGitBranch()
    return substitute(FugitiveStatusline(), '\[Git:\?\(.*\)]', '\1', '')
endfunction

" Use autocmd to force lightline update.
augroup lightline_group
    autocmd!
    autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
augroup END

" Default tab settings
set tabstop=8 softtabstop=4 shiftwidth=4 expandtab

" Other settings
set hidden              " Hide buffers when they are abandoned
set ignorecase          " Do case insensitive matching
set smartcase           " Do smart case matching
set updatetime=300      " Faster trigger CursorHold event
set scrolloff=3         " Make some context visible
set sidescrolloff=5     " Make some context visible

" Terminal settings
set scrollback=20000
augroup TerminalSettings
autocmd!
autocmd TermOpen * startinsert
" Set some global only settings (would be fixed in future versions)
autocmd TermEnter * setlocal scrolloff&
autocmd TermEnter * setlocal sidescrolloff&
autocmd TermLeave * setlocal scrolloff=3
autocmd TermLeave * setlocal sidescrolloff=5
augroup END

" Hotkeys
tnoremap <Esc><Esc> <C-\><C-n>

tnoremap <A-Left> <C-\><C-N><C-w>h
tnoremap <A-Down> <C-\><C-N><C-w>j
tnoremap <A-Up> <C-\><C-N><C-w>k
tnoremap <A-Right> <C-\><C-N><C-w>l
inoremap <A-Left> <C-\><C-N><C-w>h
inoremap <A-Down> <C-\><C-N><C-w>j
inoremap <A-Up> <C-\><C-N><C-w>k
inoremap <A-Right> <C-\><C-N><C-w>l
nnoremap <A-Left> <C-w>h
nnoremap <A-Down> <C-w>j
nnoremap <A-Up> <C-w>k
nnoremap <A-Right> <C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <silent> <leader>q :<C-u>q<CR>
nnoremap <silent> <leader>w :<C-u>w<CR>
nnoremap <silent> <leader>H :<C-u>nohlsearch<CR>

" Russian layout
inoremap <silent><expr> <M-;>
            \ (&keymap == "") ?
            \       "<C-O>:set keymap=russian-jcukenwin<CR>" :
            \       "<C-O>:set keymap=<CR>"
nnoremap <silent><expr> <M-;>
            \ (&keymap == "") ?
            \       ":set keymap=russian-jcukenwin<CR>" :
            \       ":set keymap=<CR>"
noremap! <M-Space> <C-^>
noremap! <M-a> <C-^>
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,
            \фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz,
            \Ж:

" Ansible settings
let g:ansible_unindent_after_newline = 1
let g:ansible_extra_keywords_highlight = 1
let g:ansible_template_syntaxes = {
            \ '*.sh.j2': 'sh',
            \ '*.vim.j2': 'vim',
            \ 'main.cf.j2': 'pfmain',
            \ 'ssh_config.j2': 'sshconfig',
            \ }

" MediaWiki settings
let g:mediawiki_wikilang_to_vim_overrides = {
            \ 'sls': 'sls',
            \ }
let g:mediawiki_forced_wikilang = ['bash', 'yaml', 'sls']

" Jinja settings
let g:jinja_syntax_html = 0

" Go settings (disable most features)
let g:go_jump_to_error = 0
let g:go_textobj_enabled = 0
let g:go_code_completion_enabled = 0
let g:go_play_open_browser = 0
let g:go_fmt_autosave = 0
let g:go_imports_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:go_metalinter_autosave = 0
let g:go_gopls_enabled = 0
let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_chan_whitespace_error = 1

" CoC
" Extensions
let g:coc_global_extensions = [
            \ 'coc-lists',
            \ 'coc-explorer',
            \ 'coc-git',
            \ 'coc-yank',
            \ 'coc-snippets',
            \ 'coc-syntax',
            \ 'coc-diagnostic',
            \ 'coc-json',
            \ 'coc-yaml',
            \ 'coc-pyright',
            \ 'coc-sh',
            \ 'coc-vimlsp',
            \ 'coc-markdownlint',
            \ 'coc-go',
            \ 'coc-tsserver',
            \ 'coc-eslint',
            \ ]
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes
" Completion hotkeys
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> [G <Plug>(coc-diagnostic-prev-error)
nmap <silent> ]G <Plug>(coc-diagnostic-next-error)
" Show diagnostics full info
nmap <silent> <leader>D <Plug>(coc-diagnostic-info)
" GoTo code navigation
nmap <silent> <leader>gd <Plug>(coc-definition)
nmap <silent> <leader>gD <Plug>(coc-declaration)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> <leader>gt <Plug>(coc-type-definition)
nmap <silent> <leader>gr <Plug>(coc-references)
" Show hover doc
nmap <silent> <leader>K :call CocActionAsync('doHover')<CR>
augroup coc_augroup
    autocmd!
    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Remap <C-f> and <C-b> for scroll float windows/popups.
nnoremap <expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <expr> <C-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<Right>"
inoremap <expr> <C-b> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<Left>"
" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
vnoremap <expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
vnoremap <expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
" Symbol renaming.
nmap <silent> <leader>r <Plug>(coc-rename)
nmap <silent> <leader>R <Plug>(coc-refactor)
" Formatting
nmap <silent> <leader>F <Plug>(coc-format)
xmap <silent> <leader>f <Plug>(coc-format-selected)
nmap <silent> <leader>f <Plug>(coc-format-selected)
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <silent> <leader>a <Plug>(coc-codeaction-selected)
nmap <silent> <leader>a <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current line.
nmap <silent> <leader>ac <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <silent> <leader>G <Plug>(coc-fix-current)
" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
" Mappings using CoCList:
" List of buffers
nnoremap <silent> ; :<C-u>CocList -N buffers<CR>
nnoremap <silent> <leader>b :<C-u>CocList buffers<CR>
" List of files
nnoremap <silent> <leader>t :<C-u>CocList files<CR>
" Search in files
nnoremap <silent> <leader>s :<C-u>CocList -I -A grep<CR>
" Search current word
nnoremap <silent> <leader>j
            \ :<C-u>exe 'CocList -I -A --input='.expand('<cword>').' grep'<CR>
" Search lines
nnoremap <silent> <leader>ll :<C-u>CocList -I -A lines<CR>
" Search words
nnoremap <silent> <leader>lw :<C-u>CocList -I -A words<CR>
" Search history
nnoremap <silent> <leader>lf :<C-u>CocList searchhistory<CR>
" Commands history
nnoremap <silent> <leader>lC :<C-u>CocList cmdhistory<CR>
" Select filetype
nnoremap <silent> <leader>lt :<C-u>CocList filetypes<CR>
" List of keymaps
nnoremap <silent> <leader>lk :<C-u>CocList maps<CR>
" List of vim helptags
nnoremap <silent> <leader>lh :<C-u>CocList -A helptags<CR>
" List of marks
nnoremap <silent> <leader>lm :<C-u>CocList marks<CR>
" Show all diagnostics.
nnoremap <silent> <leader>ld :<C-u>CocList -A diagnostics<CR>
" Manage extensions.
nnoremap <silent> <leader>le :<C-u>CocList extensions<CR>
" Show commands.
nnoremap <silent> <leader>lc :<C-u>CocList commands<CR>
" Show vim commands
nnoremap <silent> <leader>lv :<C-u>CocList vimcommands<CR>
" Find symbol of current document.
nnoremap <silent> <leader>lo :<C-u>CocList -A outline<CR>
" Search workleader symbols.
nnoremap <silent> <leader>ls :<C-u>CocList -I -A symbols<CR>
" Show snippets
nnoremap <silent> <leader>lS :<C-u>CocList -A snippets<CR>
" Show actions
nnoremap <silent> <leader>la :<C-u>CocList actions<CR>
" Do default action for next item.
nnoremap <silent> <leader>ln :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <leader>lp :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <leader>L :<C-u>CocListResume<CR>
" Coc-List command
nnoremap <leader>l<Space> :CocList<Space>
" Explorer
nmap <silent> <leader>e :CocCommand explorer --sources buffer+,file+<CR>
" Snippets
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)
" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)
" Git
" Navigate chunks of current buffer
nmap [h <Plug>(coc-git-prevchunk)
nmap ]h <Plug>(coc-git-nextchunk)
" Show chunk diff at current position
nmap <leader>hi <Plug>(coc-git-chunkinfo)
" Show commit contains current position
nmap <leader>hc <Plug>(coc-git-commit)
" Stage current chunk
nnoremap <silent> <leader>hs :<C-u>CocCommand git.chunkStage<CR>
" Undo current chunk
nnoremap <silent> <leader>hu :<C-u>CocCommand git.chunkUndo<CR>
" Create text object for git chunks
omap ih <Plug>(coc-git-chunk-inner)
xmap ih <Plug>(coc-git-chunk-inner)
omap ah <Plug>(coc-git-chunk-outer)
xmap ah <Plug>(coc-git-chunk-outer)
" Diff staged
nnoremap <silent> <leader>D :<C-u>CocCommand git.diffCached<CR>
" List git commits
nnoremap <silent> <leader>gc :<C-u>CocList -A commits<CR>
" List git commits for current file
nnoremap <silent> <leader>gC :<C-u>CocList -A bcommits<CR>
" List git branches
nnoremap <silent> <leader>gb :<C-u>CocList branches<CR>
" List git files
nnoremap <silent> <leader>gf :<C-u>CocList gfiles<CR>
" List git status
nnoremap <silent> <leader>gs :<C-u>CocList gstatus<CR>
" Yank
nnoremap <silent> <leader>y  :<C-u>CocList -A yank<CR>

" EasyAligh
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" MediaWiki table align
let g:easy_align_delimiters = {
            \ '!': {
            \       'pattern': '[|!]\{2\}',
            \       'left_margin': 1,
            \       'right_margin': 1,
            \       'stick_to_left': 0
            \   }
            \ }

" AutoPairs
augroup AutoPairs
    autocmd!
    " Jinja
    autocmd FileType jinja,jinja2,yaml.ansible,sls let b:AutoPairs =
                \ AutoPairsDefine({
                \   '{%': '%}',
                \   '{%-': '%}',
                \   '{#': '#}',
                \   '{#-': '#}',
                \   '{{-': '}}'
                \ })
    autocmd FileType markdown let b:AutoPairs =
                \ AutoPairsDefine({
                \   '*': '*',
                \   '**': '**',
                \   '***': '***',
                \ })
augroup end

" Gundo
nnoremap <silent> <leader>u :GundoToggle<CR>

" Better Whitespace
let g:better_whitespace_operator='<leader>x'
let g:better_whitespace_guicolor='#dc322f' " Solarized Red
let g:better_whitespace_filetypes_blacklist=['git', 'diff', 'gitsendemail', 'gitcommit', 'fugitive', 'unite', 'qf', 'help']
