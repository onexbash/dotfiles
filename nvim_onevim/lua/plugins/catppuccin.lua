return {
  "catppuccin/nvim",
  lazy = false,
  version = "2.0.0",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      background = "mocha",
      transparent_background = true,
      float = {
        transparent = true, -- transparent floating windows
        solid = false, -- solid styling for floating windows
      },
      term_colors = true, -- whether to use the Terminal Emulator or nvim colorscheme for Terminal Buffers inside of nvim
      dim_inactive = {
        enabled = true, -- dims the background of inactive windows
        shade = "dark",
        percentage = 0.10,
      },
      no_italic = false,
      no_bold = false,
      no_underline = false,
      auto_integrations = false,
      integrations = {
        telescope = {
          enabled = true,
          style = "nvchad",
        },
        alpha = true,
        treesitter = true,
        markdown = true,
      },
      -- custom color overrides
      custom_highlights = function(colors)
        return {
          Comment = { fg = colors.overlay0 },
          CursorLineNr = { fg = colors.green },
        }
      end,
    })
    vim.cmd.colorscheme("catppuccin-nvim")
  end,
}
