-- |   UTILITIES   | --

-- Colors
require("utils.colors").setup({
  theme = "catppuccin-mocha",
  color_format = "hex",
  highlights = {
    Comment = { fg = "light_gray_5", italic = true },
    LineNr = { fg = "dark_gray_2" },
    CursorLineNr = { fg = "green", bold = true },
    Floatborder = { fg = "purple", bg = "dark_gray_4" },
  }
})
