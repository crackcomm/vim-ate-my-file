vim.filetype.add({
  extension = {
    fbs = "fbs", -- Associate `.fbs` files with the `fbs` filetype
    sky = "bzl",
    star = "bzl",
    atd = "ocaml",
    td = "tablegen",
  },
})

-- Set the comment string for the `fbs` filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fbs", -- Trigger for the `fbs` filetype
  callback = function()
    vim.bo.commentstring = "// %s" -- Set the comment format to `//`
  end,
})
