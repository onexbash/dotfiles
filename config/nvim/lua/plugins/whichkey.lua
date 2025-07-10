return {
  "folke/which-key.nvim",
  dependencies = { "echasnovski/mini.icons" },
  event = { "VeryLazy" },
  opts = {},
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "whichkey: local keymaps",
    },
  },
}
