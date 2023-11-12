augroup filetype
  au! BufReadPost,BufNewFile *.atd set syntax=ocaml
augroup END

augroup filetype
  au! BufReadPost,BufNewFile *.td set syntax=tablegen
augroup END

" augroup filetype
"   au! BufReadPost,BufNewFile *.sky set syntax=bzl
"   au! BufReadPost,BufNewFile *.BUILD set syntax=bzl
"   au! BufReadPost,BufNewFile BUILD.* set syntax=bzl
"   au! BufReadPost,BufNewFile BUILD set syntax=bzl
"   au! BufReadPost,BufNewFile WORKSPACE set syntax=bzl
"   au! BufReadPost,BufNewFile MODULE set syntax=bzl
"   au! BufReadPost,BufNewFile MODULE.bazel set syntax=bzl
" augroup END
