return {
  {
  -- Git Diff Pager
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { "VimEnter" },
    keys = {
      "<Leader>gd",
      "<cmd>DiffviewOpen<cr>",
      mode = "n",
      desc = 'Open Git Diff View',
    },
  }
}
