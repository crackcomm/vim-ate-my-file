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
