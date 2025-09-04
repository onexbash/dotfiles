-- MASON INSTALLATION --
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "williamboman/mason.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_tool_installer = require("mason-tool-installer")
    mason.setup({
        ui = {
          border = "single",
        },
        registries = {
          "github:nvim-java/mason-registry",
          "github:mason-org/mason-registry",
        },
      })
    mason_tool_installer.setup({
      ensure_installed = {
        -- language servers
        "bashls",
        "clangd",
        "cssls",
        "gopls",
        "html-lsp",
        "lua_ls",
        "tailwindcss",
        "ts_ls",
      },
    })
  end
}

