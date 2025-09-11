return {
  "akinsho/bufferline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  keys = {
    -- navigate tab tab(left)
    {
      "<C-Left>",
      function()
        require("bufferline").cycle(-1)
      end,
      desc = "bufferline  navigate tab (left)",
    },
    -- navigate tab tab(right)
    {
      "<C-Right>",
      function()
        require("bufferline").cycle(1)
      end,
      desc = "bufferline  navigate tab (right)",
    },
    -- move tab tab(left)
    {
      "<S-Left>",
      function()
        require("bufferline").move(-1)
      end,
      desc = "bufferline  move tab (left)",
    },
    -- move tab tab(right)
    {
      "<S-Right>",
      function()
        require("bufferline").move(1)
      end,
      desc = "bufferline  move tab (right)",
    },
    -- pin/unpin tab
    {
      "<S-Down>",
      function()
        require("bufferline").toggle_pin()
      end,
      desc = "bufferline  pin/unpin tab",
    },
    -- unpin tab
    -- close tab
    {
      "<leader>q",
      function()
        require("bufferline").unpin_and_close()
      end,
      desc = "bufferline  close tab",
    },
  },
}
