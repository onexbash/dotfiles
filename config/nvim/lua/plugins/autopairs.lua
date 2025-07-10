return {
  -- | AUTOBRACKETS | --
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    opts = {
      fast_wrap = {
        map = "<C-Right>",
        before_key = "1",
        after_key = "2",
        end_key = "$",
      },
    },
  },
  -- | AUTOTAG | --
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" },
    opts = {
      opts = {
        enable_close = true, -- auto close tags
        enable_rename = true, -- auto rename tags
        enable_close_on_slash = true, -- auto close on trailing slash </
      },
    },
  },
  -- | SURROUND | --
  {
    "kylechui/nvim-surround",
    event = { "VeryLazy" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      keymaps = {
        visual = "s",
        -- disable all other keymaps as visual is all you need
        insert = false,
        insert_line = false,
        normal = false,
        normal_cur = false,
        normal_line = false,
        normal_cur_line = false,
        visual_line = false,
        delete = false,
        change = false,
        change_line = false,
      },
    },
  },
}
