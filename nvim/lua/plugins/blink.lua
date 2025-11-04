return {
  "saghen/blink.cmp",
  lazy = true,
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = { "rafamadriz/friendly-snippets", "L3MON4D3/LuaSnip", "neovim/nvim-lspconfig" },
  version = "1.*",
  opts = {
    -- Keymaps
    keymap = { preset = "super-tab" }, -- default / super-tab(vscode) / enter / none
    -- Appearance
    appearance = {
      nerd_font_variant = "mono",
    },
    -- Completion
    completion = {
      accept = { auto_brackets = { enabled = true } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 250,
        treesitter_highlighting = true,
        update_delay_ms = 50,
        window = { border = "rounded" },
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
      menu = {
        border = "rounded",
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind" },
          },
          treesitter = { "lsp" },
        },
      },
      trigger = { show_in_snippet = false },
    },
    -- Sources
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          enabled = true,
          min_keyword_length = 2,
          score_offset = 100,
        },
        snippets = {
          enabled = true,
          min_keyword_length = 2,
          score_offset = 50,
        },
        buffer = {
          enabled = true,
          min_keyword_length = 4,
          max_items = 5,
          score_offset = 25,
        },
        path = {
          enabled = true,
          min_keyword_length = 0,
          score_offset = 0,
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
