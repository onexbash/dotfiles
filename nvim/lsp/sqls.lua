return {
  root_dir = function(bufnr, on_dir)
    if vim.fs.root(bufnr, { "postgres-language-server.jsonc" }) then return end
    on_dir(vim.fs.root(bufnr, { "config.yml", ".git" }) or vim.fn.getcwd())
  end,
}
