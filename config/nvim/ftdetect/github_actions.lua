-- github actions
vim.filetype.add({
  pattern = {
    ['.github/workflows/.*%.yml'] = 'github-actions',
    ['.github/workflows/.*%.yaml'] = 'github-actions',
  },
})
