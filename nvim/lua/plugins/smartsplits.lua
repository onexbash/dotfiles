return {
  "mrjones2014/smart-splits.nvim",
  opts = {
    ignored_buftypes = {
    'nofile',
    'quickfix',
    'prompt'
  },
    ignored_filetypes = {},
    default_amount = 3 -- number of lines/columns to resize
  },
  keys = {
    -- Resizing splits
    { "<C-Left>", function() require("smart-splits").resize_left() end, desc = "Resize left" }, -- ctrl + <-
    { "<C-Down>", function() require("smart-splits").resize_down() end, desc = "Resize down" }, -- ctrl + 
    { "<C-Right>", function() require("smart-splits").resize_right() end, desc = "Resize right" }, -- ctrl + ->
    { "<C-Up>", function() require("smart-splits").resize_up() end, desc = "Resize up" },

    -- Moving between splits
    { "<A-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move cursor left" }, -- option + h
    { "<A-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move cursor down" }, -- option + j
    { "<A-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move cursor up" }, -- option + k
    { "<A-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move cursor right" }, -- option + l

    -- Swapping buffers between windows
    { "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
    { "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
    { "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
    { "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" }
  }
}
