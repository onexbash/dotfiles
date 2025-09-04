return {
  "nvim-pack/nvim-spectre",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = { "VimEnter" },
  branch = "master",
  -- -- -- -- -- --
  --   KEYMAPS   --
  keys = {
    {
      -- spectre: toggle
      "<leader>ss",
      function()
        require("spectre").toggle()
      end,
      mode = { "n" },
      desc = "spectre: toggle",
    },
    -- spectre: search selected word
    {
      "<leader>sw",
      function()
        require("spectre").open_visual()
      end,
      mode = { "v" },
      desc = "spectre: search selected word",
    },
    -- spectre: search on current file
    {
      "<leader>sf",
      function()
        require("spectre").file_search({ select_word = true })
      end,
      mode = { "v" },
      desc = "spectre: search on current file",
    },
  },
  -- -- -- -- -- --
  -- PLUGIN OPTS --
  opts = {
    live_updates = true,
  },
}
