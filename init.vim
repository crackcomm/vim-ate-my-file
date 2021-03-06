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
  Plug 'neoclide/coc.nvim'
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
  Plug 'tomtom/tlib_vim'
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
  Plug 'mattn/webapi-vim'
  Plug 'mattn/vim-gist'
call plug#end()

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

let g:neoformat_enabled_ocaml = ['ocamlformat']
let g:neoformat_enabled_go = ['goimports']

" Format on save
"augroup fmt
"  autocmd!
"  autocmd BufWritePre * undojoin | Neoformat
"augroup END
nnoremap <leader>rd :Neoformat<CR>

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
let NERDTreeIgnore = ['\.pyc$', '\.log$', '_esy', 'esy.lock', 'node_modules', 'target']

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

function! s:show_documentation()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

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

" NERDTree
" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'c',
                \ 'Staged'    :'+',
                \ 'Untracked' :'n',
                \ 'Renamed'   :'m',
                \ 'Unmerged'  :'???',
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
highlight clear SignColumn
highlight GitGutterAdd ctermfg=2
highlight GitGutterChange ctermfg=3
highlight GitGutterDelete ctermfg=1
highlight GitGutterChangeDelete ctermfg=4

