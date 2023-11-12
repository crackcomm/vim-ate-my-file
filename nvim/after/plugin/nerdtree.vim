" NERDTree
let NERDTreeIgnore = ['\.pyc$', '\.log$', '^_esy', '^_build', 'esy.lock', 'node_modules', '^target', '^bazel-', '^__py', '\.opam$']
let NERDTreeWinSize = 30

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

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>b :NERDTreeToggle<CR>
nnoremap <leader>lf :NERDTreeFind<CR>
