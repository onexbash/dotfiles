vim.filetype.add({
  pattern = {
    ['.*/%.gitlab%-ci%.yml'] = 'yaml.gitlab',
  },
})
