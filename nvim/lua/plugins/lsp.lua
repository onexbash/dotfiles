local lsp_list = {
  "ansiblels",
  "awk_ls",
  "azure_pipelines_ls",
  "bashls",
  "clangd",
  "csharp_ls",
  "css_variables",
  "cssls",
  "docker_compose_language_service",
  "docker_language_server",
  "gh_actions_ls",
  "gitlab_ci_ls",
  "gopls",
  "golangci_lint_ls",
  "eslint",
  "graphql",
  "html",
  "htmx",
  "intelephense",
  -- "java_language_server",
  "jinja_lsp",
  "jsonls",
  "lua_ls",
  "marksman",
  "postgres_lsp",
  "powershell_es",
  "prismals",
  "ruff",
  "somesass_ls",
  "sqls",
  "stylelint_lsp",
  "svelte",
  "systemd_ls",
  "tailwindcss",
  "terraformls",
  "taplo",
  "tflint",
  "ts_ls",
  "vimls",
  "yamlls",
}

return {
  -- mason
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    event = { "VimEnter" },
    dependencies = { { "williamboman/mason.nvim", opts = {} } },
    opts = {
      ensure_installed = lsp_list,
    },
  },
  -- lsp-config
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      -- Enable all LSP's from lsp_list{}
      for _, lsp_name in ipairs(lsp_list) do
        vim.lsp.enable(lsp_name)
      end
    end,
  },
}
