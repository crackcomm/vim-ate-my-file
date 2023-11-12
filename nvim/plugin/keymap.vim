" Paste without overwriting register
xnoremap p pgvy

" Unmap F9 in insert mode
imap <F9> <nop>
nnoremap <F1> <C-PageUp>
nnoremap <F2> <C-PageDown>
nnoremap <C-]> :tabnext<CR>

" Copy to system clipboard
noremap <leader>y "+y
nnoremap <leader>g :let @+=expand('%:p:~:.')<CR>:echo 'Relative file path copied to clipboard'<CR>

" Split vertical
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>ss :split<CR>
nnoremap <leader>st :tab split<CR>

" Replace all alias
nnoremap S :%s//g<Left><Left>

" Search for selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Format the file
nnoremap <leader>rd :Neoformat<CR>

" Save on ss
nmap <silent> ss :Neoformat<CR>:w<CR>

" Disable Arrow keys in Normal mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Telescope
nnoremap <space>t :Telescope<CR>
" Rep-grip through files
nnoremap <leader>a :Telescope live_grep<CR>
" Find in filenames
nnoremap <leader>f :Telescope find_files<CR>

" Move lines with <alt+key>
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" OCaml
augroup OCamlgroup
  autocmd!
  nmap <silent>mi <Plug>OCamlSwitchEdit
  "autocmd FileType is not working
  "autocmd FileType ml,mli nmap <leader>hg <Plug>OCamlSwitchEdit
augroup END

" Snippets
" let g:UltiSnipsExpandTrigger="<c-s>"
" nnoremap <leader>us :Snippets<CR>
