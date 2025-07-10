return {
  "L3MON4D3/LuaSnip",
  enabled = true,
  event = { "InsertEnter" },
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    history = true,
    updateevents = "TextChanged,TextChangedI",
  },
  keys = function()
    return {}
  end,
  config = function()
    -- load snippets: vscode format
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { "~/.config/nvim" },
    })
  end,
}
