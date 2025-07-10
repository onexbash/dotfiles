return {
  cmd = { 'some-sass-language-server', '--stdio' },
  filetypes = { 'scss', 'sass' },
  name = 'somesass_ls',
  root_markers = { '.git', '.package.json' },
  settings = {
    somesass = {
      suggestAllFromOpenDocument = true,
    },
  },
}
