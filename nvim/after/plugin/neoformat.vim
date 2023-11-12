" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
let g:NERDCommentEmptyLines = 1

" Align multi line comments
let g:NERDDefaultAlign = 'left'

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

let g:neoformat_bzl_buildifier = {
  \ 'exe': 'buildifier',
  \ 'args': ['-lint=fix', '-path', '"%:p"'],
  \ 'stdin': 1,
  \ 'no_append': 1,
  \ }

let g:neoformat_proto_clangformat = {
  \ 'exe': 'clang-format',
  \ 'args': ['-assume-filename=' . expand('"%"')],
  \ 'stdin': 1,
  \ }

let g:neoformat_python_ruff = {
  \ 'exe': 'ruff',
  \ 'args': ['format', '-'],
  \ 'stdin': 1,
  \ }

let g:neoformat_enabled_ocaml = ['ocamlformat']
let g:neoformat_go = ['gofumpt', 'goimports']
let g:neoformat_enabled_python = ['ruff']
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_typescript = ['prettier']
let g:neoformat_enabled_typescriptreact = ['prettier']
let g:neoformat_enabled_lua = ['stylua']
let g:neoformat_enabled_proto = ['clangformat']

" Format on save
"augroup fmt
"  autocmd!
"  autocmd BufWritePre * undojoin | Neoformat
"augroup END
