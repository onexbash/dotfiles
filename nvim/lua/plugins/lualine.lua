return {
  "nvim-lualine/lualine.nvim",
  event = { "BufEnter", "BufReadPre" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local icons = require("utils.icons")
    local lualine = require("lualine")
    -- local catppuccin = require("lualine.themes.catppuccin")
    local colors = require("catppuccin.palettes").get_palette("mocha")
    local options = require("catppuccin").options
    local transparent = options.transparent_background and "NONE" or colors.base

    local onexcol = {
      bg1 = colors.base,
      bg2 = colors.surface0,
      bg3 = transparent,
      fg1 = colors.text,
      fg2 = colors.base,
      accent = {
        normal = colors.mauve,
        insert = colors.green,
        terminal = colors.yellow,
        command = colors.pink,
        visual = colors.blue,
        replace = colors.red,
        inactive = colors.surface2,
      },
    }
    local onexcat = {
      normal = {
        a = { bg = onexcol.accent.normal, fg = onexcol.fg2, gui = "bold" },
        b = { bg = onexcol.bg2, fg = onexcol.fg1 },
        c = { bg = onexcol.bg3, fg = onexcol.fg1 },
        x = { bg = onexcol.bg3, fg = onexcol.fg1 },
        y = { bg = onexcol.bg2, fg = onexcol.fg1 },
        z = { bg = onexcol.accent.normal, fg = onexcol.fg2, gui = "bold" },
      },
      insert = {
        a = { bg = onexcol.accent.insert, fg = onexcol.fg2, gui = "bold" },
        b = { bg = onexcol.bg2, fg = onexcol.fg1 },
        c = { bg = onexcol.bg3, fg = onexcol.fg1 },
        x = { bg = onexcol.bg3, fg = onexcol.fg1 },
        y = { bg = onexcol.bg2, fg = onexcol.fg1 },
        z = { bg = onexcol.accent.insert, fg = onexcol.fg2, gui = "bold" },
      },
    }
    -- background
    -- onexcat.normal.a.bg = colors.mauve
    -- onexcat.normal.b.bg = colors.surface1
    -- onexcat.normal.c.bg = colors.base
    -- onexcat.normal.x.bg = colors.base
    -- onexcat.normal.y.bg = colors.surface1
    -- onexcat.normal.z.bg = colors.mauve
    -- -- foreground
    -- onexcat.normal.a.fg = colors.base
    -- onexcat.normal.b.fg = colors.text
    -- onexcat.normal.c.fg = colors.text
    -- onexcat.normal.x.fg = colors.text
    -- onexcat.normal.y.fg = colors.text
    -- onexcat.normal.z.fg = colors.base

    lualine.setup({
      options = {
        theme = onexcat,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            -- show filename + max. 3 parent directories
            function()
              local path = vim.fn.expand("%:p")
              local filename = vim.fn.expand("%:t")
              if path == "" then
                return "[No Name]"
              end
              local parts = vim.split(path, "/")
              -- handle empty buffer
              if parts[1] == "" then
                table.remove(parts, 1)
              end
              local len = #parts
              -- if 4 or less parts, show absolute filepath
              if len <= 4 then
                return "/" .. table.concat(parts, "/")
              end
              -- if more than 4 parts, show the last 3 parent directories + filename
              local result = {}
              for i = len - 3, len do
                table.insert(result, parts[i])
              end
              return "../" .. table.concat(result, "/")
            end,
          },
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
        },
        lualine_x = { "branch" },
        lualine_y = { "filetype" },
        lualine_z = { "location" },
      },
    })
  end,
}
