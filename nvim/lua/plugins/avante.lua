return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- required!
    "nvim-lua/plenary.nvim", -- required!
    "MunifTanjim/nui.nvim", -- required!
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "Saghen/blink.cmp",
    "Kaiser-Yang/blink-cmp-avante", -- compatibility plugin to make blink-cmp integration possible
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "stevearc/dressing.nvim", -- for input provider dressing
    "folke/snacks.nvim", -- for input provider snacks
    "echasnovski/mini.icons",
  },
  opts = {
    auto_suggestions_provider = "claude",
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-20241022",
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 4096,
        },
      },
    },
    -- selector = {
    --   provider = function(selector)
    --     local blink = require("blink")
    --     local picker = blink.create_picker({
    --       items = selector.items,
    --       render_item = function(self, item, is_selected)
    --         -- Custom rendering (e.g., add icons)
    --         local icon = " " -- nerd font icon
    --         return string.format("%s %s", icon, item.label)
    --       end,
    --       on_select = function(selected_ids)
    --         selector.on_select(selected_ids)
    --       end,
    --     })
    --     picker:open()
    --   end,
    -- },
  },
}
