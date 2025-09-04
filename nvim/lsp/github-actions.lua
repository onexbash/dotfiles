return {
  cmd = { 'gh-actions-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.github/workflows', '.forgejo/workflows', '.gitea/workflows' },
  workspace_required = true,
  capabilities = {
    workspace = {
      didChangeWorkspaceFolders = {
        dynamicRegistration = true,
      },
    },
  },
}
