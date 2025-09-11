return {
  "mrjones2014/smart-splits.nvim",
  opts = {
    ignored_buftypes = {
    'nofile',
    'quickfix',
    'prompt'
  },
    ignored_filetypes = {},
    default_amount = 15 -- number of lines/columns to resize
  },
  keys = {
    -- Resizing splits
    { "<leader><leader>h", function() require("smart-splits").resize_left() end, desc = "Resize left" }, -- ctrl + <-
    { "<leader><leader>j", function() require("smart-splits").resize_down() end, desc = "Resize down" }, -- ctrl + 
    { "<leader><leader>k", function() require("smart-splits").resize_up() end, desc = "Resize up" }, -- ctrl + 
    { "<leader><leader>l", function() require("smart-splits").resize_right() end, desc = "Resize right" }, -- ctrl + ->

    -- Moving between splits
    { "<Left>", function() require("smart-splits").move_cursor_left() end, desc = "Move cursor left" }, -- option + h
    { "<Down>", function() require("smart-splits").move_cursor_down() end, desc = "Move cursor down" }, -- option + j
    { "<Up>", function() require("smart-splits").move_cursor_up() end, desc = "Move cursor up" }, -- option + k
    { "<Right>", function() require("smart-splits").move_cursor_right() end, desc = "Move cursor right" }, -- option + l

    -- Swapping buffers between windows
    { "<leader><leader>H", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
    { "<leader><leader>J", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
    { "<leader><leader>K", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
    { "<leader><leader>L", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" }
  }
}
