return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false, -- lazy loading doesn't work for colorschemes
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      background = "mocha",
      transparent_background = true,
      term_colors = true,
      default_integrations = false, -- disabled as manually set
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
    vim.cmd.colorscheme("catppuccin")
  end,
}
