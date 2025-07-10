return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        background_colour = "#24273a",
      },
    },
  },
  opts = {
    cmdline = {
      view = "cmdline" -- [cmdline_popup | cmdline]
    },
  },
}
