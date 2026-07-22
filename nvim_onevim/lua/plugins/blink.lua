return {
  "saghen/blink.cmp",
  version = "2.0.0",
  dependencies = {
    "saghen/blink.lib", -- required for blink v2.0+
    "rafamadriz/friendly-snippets", -- provides snippets
  },
  build = function()
    require('blink.cmp').build():pwait()
  end,
  config = function()
  end,
}
