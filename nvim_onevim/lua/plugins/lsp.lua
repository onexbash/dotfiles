return {
  -- nvim-lspconfig
  "mason-org/mason-lspconfig.nvim",
  lazy = false,
  version = "2.11.0",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
  config = function()
    -- LSP Defaults
    -- vim.lsp.config("*", {
    --   capabilities = vim.tbl_deep_extend(
    --     "force",
    --     vim.lsp.protocol.make_client_capabilities(),
    --     require("blink.cmp").get_lsp_capabilities()
    --   ),
    -- })

    -- SETUP > mason.nvim
    local mason = require("mason")
    mason.setup({
      firewall = {
        enabled = true, -- enables the socket.dev firewall for mason pkg downloads
        auto_managed = true, -- if this is set to false, the sfw binary is required in $PATH
      },
      ui = {
        border = "single", -- single/double/rounded/solid/shadow/none
        backdrop = 60, -- transparency
        width = 0.8,
        height = 0.9,
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- SETUP > mason-lspconfig.nvim
    local mason_lspconfig = require("mason-lspconfig")
    mason_lspconfig.setup({
      automatic_enable = true,
      ensure_installed = {
        "ansiblels",
        "rust_analyzer",
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "yamlls",
        "ruff"
      },
    })

  end,
}
