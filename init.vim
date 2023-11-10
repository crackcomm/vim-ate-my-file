set nocompatible

let mapleader = ","

call plug#begin('~/.vim/plugged')
  Plug 'preservim/nerdcommenter'
  Plug 'sbdchd/neoformat'
  Plug 'tpope/vim-abolish'
  Plug 'tpope/vim-fugitive'
  Plug 'airblade/vim-gitgutter'
  Plug 'preservim/nerdtree'
  Plug 'mg979/vim-visual-multi'
  Plug 'fatih/vim-go'
  Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
  Plug 'dcharbon/vim-flatbuffers'
  Plug 'bfrg/vim-cpp-modern'
  Plug 'romainl/vim-cool'
  Plug 'rainglow/vim'
  Plug 'pboettch/vim-cmake-syntax'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'ekalinin/Dockerfile.vim'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'wookayin/fzf-ripgrep.vim'
  Plug 'jreybert/vimagit'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'ocaml/vim-ocaml'
  Plug 'aonemd/quietlight.vim'
  Plug 'tomtom/tlib_vim'
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
  Plug 'mattn/webapi-vim'
  Plug 'mattn/vim-gist'
  Plug 'leafgarland/typescript-vim'
call plug#end()

" Paste without overwriting register
xnoremap p pgvy

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
let g:NERDCommentEmptyLines = 1

" Align multi line comments
let g:NERDDefaultAlign = 'left'

augroup filetype
  au! BufReadPost,BufNewFile *.atd set syntax=ocaml
augroup END

augroup filetype
  au! BufReadPost,BufNewFile *.td set syntax=tablegen
augroup END

augroup filetype
  au! BufReadPost,BufNewFile *.sky set syntax=python
  au! BufReadPost,BufNewFile *.BUILD set syntax=python
  au! BufReadPost,BufNewFile BUILD.* set syntax=python
  au! BufReadPost,BufNewFile BUILD set syntax=python
  au! BufReadPost,BufNewFile WORKSPACE set syntax=python
  au! BufReadPost,BufNewFile MODULE set syntax=python
  au! BufReadPost,BufNewFile MODULE.bazel set syntax=python
augroup END

" Unmap F9 in insert mode
imap <F9> <nop>
nnoremap <F1> <C-PageUp>
nnoremap <F2> <C-PageDown>
nnoremap <C-]> :tabnext<CR>

" Copy to system clipboard
noremap <Leader>y "+y

" Split vertical
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>ss :split<CR>
nnoremap <leader>st :tab split<CR>

" Replace all alias
nnoremap S :%s//g<Left><Left>

" Search for selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

function RandomColorScheme()
  let mycolors = split(globpath(&rtp,"**/colors/*.vim"),"\n") 
  let color = mycolors[localtime() % len(mycolors)]
  exe 'so ' . color
  echo color
  unlet mycolors
  call MyHighlights()
endfunction

:command! NewColor call RandomColorScheme()
nnoremap <leader>rc :NewColor<CR>

" Snippets
let g:UltiSnipsExpandTrigger="<c-s>"

" Neoformat
let g:neoformat_ocaml_ocamlformat = {
  \ 'exe': 'esy',
  \ 'args': ['ocamlformat', '--name', '"%:p"', '-'],
  \ 'no_append': 1,
  \ 'stdin': 1,
  \ }

let g:neoformat_dune_dune = {
  \ 'exe': 'esy',
  \ 'args': ['dune', 'format-dune-file'],
  \ 'no_append': 1,
  \ 'stdin': 1,
  \ }

let g:neoformat_enabled_ocaml = ['ocamlformat']
let g:neoformat_enabled_go = ['goimports', 'gofmt']
let g:neoformat_enabled_python = ['black']
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_typescript = ['prettier']

" Format on save
"augroup fmt
"  autocmd!
"  autocmd BufWritePre * undojoin | Neoformat
"augroup END
nnoremap <leader>rd :Neoformat<CR>
nnoremap <leader>gg :Neoformat<CR>:w<CR>

" Save on ss
nmap <silent> ss :Neoformat<CR>:w<CR>

" Disable Arrow keys in Normal mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" fzf
let rg_def_exe = "rg"
let rg_def_opts = ['--ansi', '--prompt', 'Rg> ',
      \ '--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
      \ '--delimiter', ':', '--preview-window', '+{2}-/2']
command! -bang -nargs=* Rg call fzf#vim#grep(rg_def_exe.shellescape(<q-args>), 1, rg_def_opts, <bang>0)

nnoremap <leader>a :Rg<CR>
nnoremap <leader>f :Files<CR>

" NERDTree
let NERDTreeIgnore = ['\.pyc$', '\.log$', '^_esy', '^_build', 'esy.lock', 'node_modules', '^target', '^bazel-', '^__py', '\.opam$']

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>b :NERDTreeToggle<CR>
nnoremap <leader>lf :NERDTreeFind<CR>

" OCaml
augroup OCamlgroup
  autocmd!
  nmap <silent>mi <Plug>OCamlSwitchEdit
  "autocmd FileType is not working
  "autocmd FileType ml,mli nmap <leader>hg <Plug>OCamlSwitchEdit
augroup END

" Coc
set updatetime=200
set shortmess+=c

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>qf <Plug>(coc-fix-current)
nmap <leader>u <Plug>(coc-rename)
nmap <space>d :CocCommand workspace.diagnosticRelated<CR>

augroup Cppgroup
  autocmd!
  autocmd FileType cc,cpp,c,h nmap <leader>hh :CocCommand clangd.switchSourceHeader split<CR>
  autocmd FileType cc,cpp,c,h nmap <leader>hv :CocCommand clangd.switchSourceHeader vsplit<CR>
  autocmd FileType cc,cpp,c,h nmap <silent>gh :CocCommand clangd.switchSourceHeader<CR>
augroup END

nnoremap <silent> K :call <SID>show_documentation()<CR>

if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" Rebuild.
nnoremap <silent><nowait> <space>r  :<C-u>CocRestart<CR>

function! s:show_documentation()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Move lines with <alt+key>
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Magit
let g:magit_default_fold_level = 1

" Git gutter
let g:gitgutter_max_signs = -1
let g:gitgutter_map_keys = 0
let g:gitgutter_override_sign_column_highlight = 0

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'c',
                \ 'Staged'    :'+',
                \ 'Untracked' :'n',
                \ 'Renamed'   :'m',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'x',
                \ 'Dirty'     :'.',
                \ 'Ignored'   :'-',
                \ 'Clean'     :'@',
                \ 'Unknown'   :'?',
                \ }


" Theme
syntax enable
set termguicolors
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set background=dark
set relativenumber
set signcolumn=yes
colorscheme stasis-contrast

function MyHighlights()
  highlight TabLine guibg=NONE gui=NONE
  highlight clear SignColumn
  highlight GitGutterAdd ctermfg=2
  highlight GitGutterChange ctermfg=3
  highlight GitGutterDelete ctermfg=1
  highlight GitGutterChangeDelete ctermfg=4
  " Used by coc unused variables
  highlight Error guibg=#470404
  highlight Conceal guibg=#1a1a1a
  highlight CocWarningHighlight guibg=#141414
  highlight CocErrorSign guifg=#400707
  highlight CocWarningSign guifg=#422d18
  highlight CocWarningHighlight gui=NONE
  highlight FgCocErrorFloatBgCocFloating guifg=#b51010
  highlight FgCocWarningFloatBgCocFloating guifg=#a15e1d
endfunction

call MyHighlights()
