local function migrate_to_svelte_5()
  local clients = vim.lsp.get_clients({
    bufnr = 0,
    name = 'svelte',
  })
  for _, client in ipairs(clients) do
    client:exec_cmd({
      command = 'migrate_to_svelte_5',
      arguments = { vim.uri_from_bufnr(0) },
    })
  end
end

return {
  cmd = { 'svelteserver', '--stdio' },
  filetypes = { 'svelte' },
  root_markers = { 'package.json', '.git' },
  on_attach = function()
    vim.api.nvim_buf_create_user_command(
      0,
      'MigrateToSvelte5',
      migrate_to_svelte_5,
      { desc = 'Migrate Component to Svelte 5 Syntax' }
    )
  end,
}
