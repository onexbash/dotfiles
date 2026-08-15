return {
  "MagicDuck/grug-far.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  event = "VimEnter",
  -- Find and Replace Keymaps
  keys = {
    {
      "<leader>frr",
      function()
        require('grug-far').open({ prefills = { search = vim.fn.expand("<cword>") }, transient = true })
      end,
      mode = "n",
      desc = "Find Replace: with word under cursor",
    },
    {
      "<leader>fra",
      function()
        require('grug-far').open({ engine = 'astgrep', transient = false })
      end,
      mode = "n",
      desc = "Find Replace: with astgrep engine",
    },
    {
      "<leader>frv",
      function()
        require('grug-far').open({ visualSelectionUsage = 'operate-within-range', transient = true })
      end,
      mode = "v",
      desc = "Find Replace: inside of visual selection",
    },
  },
  config = function()
    require("grug-far").setup({})
  end
}
