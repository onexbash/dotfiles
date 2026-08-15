return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.2.2",
  -- version = "*",
  -- branch = "master",
  event = { "BufNewFile", "BufReadPre" },
  cmd = { "Telescope" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    -- Find Files
    {
      "<leader>ff",
      function()
        require('telescope.builtin').find_files()
      end,
      mode = { "n", "v" },
      desc = "Telescope: find files",
    },
    -- Live Grep
    {
      "<leader>fg",
      function()
        require('telescope.builtin').live_grep()
      end,
      mode = { "n", "v" },
      desc = "Telescope: live grep",
    },
    -- Buffers
    {
      "<leader>fb",
      function()
        require('telescope.builtin').buffers()
      end,
      mode = { "n", "v" },
      desc = "Telescope: buffers",
    },
    -- Help Tags
    {
      "<leader>fh",
      function()
        require('telescope.builtin').help_tags()
      end,
      mode = { "n", "v" },
      desc = "Telescope: help tags",
    },
  },
}
