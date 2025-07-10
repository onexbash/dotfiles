return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "mason-org/mason.nvim"
  },
  init = function ()
    local lang_servers = require("utils.tools").lang_servers
    for lsp_name, _ in pairs(lang_servers) do
      vim.lsp.enable(lsp_name)
    end
  end,
}
