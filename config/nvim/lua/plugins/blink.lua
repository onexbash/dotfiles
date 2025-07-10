-- NOTE: Specify the trigger character(s) used for luasnip
local trigger_text = ';'

return {
  'saghen/blink.cmp',
  enabled = true,
  -- In case there are breaking changes and you want to go back to the last
  -- working release
  -- https://github.com/Saghen/blink.cmp/releases
  -- version = "v0.13.1",
  dependencies = {
    "neovim/nvim-lspconfig",
    'moyiz/blink-emoji.nvim',
    'Kaiser-Yang/blink-cmp-dictionary',
    "Kaiser-Yang/blink-cmp-avante", -- avante source for blink
  },
  init = function ()
    -- highlight colors
    vim.api.nvim_set_hl(0, 'BlinkCmpKindAvante', { default = false, fg = '#cba6f7' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindAvanteCmd', { default = false, fg = '#f38ba8' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindAvanteMention', { default = false, fg = '#89dceb' })
  end,
  opts = function(_, opts)
    -- I noticed that telescope was extremeley slow and taking too long to open,
    -- assumed related to blink, so disabled blink and in fact it was related
    -- :lua print(vim.bo[0].filetype)
    -- So I'm disabling blink.cmp for Telescope
    opts.enabled = function()
      -- Get the current buffer's filetype
      local filetype = vim.bo[0].filetype
      -- Disable for Telescope buffers
      if filetype == 'TelescopePrompt' or filetype == 'minifiles' or filetype == 'snacks_picker_input' then
        return false
      end
      return true
    end

    -- NOTE: The new way to enable LuaSnip
    -- Merge custom sources with the existing ones from lazyvim
    -- NOTE: by default lazyvim already includes the lazydev source, so not adding it here again
    opts.sources = vim.tbl_deep_extend('force', opts.sources or {}, {
      default = { 'lsp', 'avante' , 'path', 'snippets', 'buffer', 'dadbod', 'emoji' },
      providers = {
        lsp = {
          name = 'lsp',
          enabled = true,
          module = 'blink.cmp.sources.lsp',
          min_keyword_length = 2,
          score_offset = 90, -- the higher the number, the higher the priority
        },
        avante = {
          module = 'blink-cmp-avante',
          name = 'Avante',
          opts = {
          score_offset = 80, -- the higher the number, the higher the priority
            avante = {
                command = {
                    get_kind_name = function()
                        return 'AvanteCmd'
                    end
                },
                mention = {
                    get_kind_name = function()
                        return 'AvanteMention'
                    end
                }
            },
            kind_icons = {
              AvanteCmd = "󱚤",
              AvanteMention = "󱩒",
            }
            }
          },
        path = {
          name = 'Path',
          module = 'blink.cmp.sources.path',
          score_offset = 25,
          -- When typing a path, I would get snippets and text in the
          -- suggestions, I want those to show only if there are no path
          -- suggestions
          fallbacks = { 'snippets', 'buffer' },
          -- min_keyword_length = 2,
          opts = {
            trailing_slash = false,
            label_trailing_slash = true,
            get_cwd = function(context)
              return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
            end,
            show_hidden_files_by_default = true,
          },
        },
        buffer = {
          name = 'Buffer',
          enabled = true,
          max_items = 3,
          module = 'blink.cmp.sources.buffer',
          min_keyword_length = 2,
          score_offset = 15, -- the higher the number, the higher the priority
        },
        snippets = {
          name = 'snippets',
          enabled = true,
          max_items = 15,
          min_keyword_length = 2,
          module = 'blink.cmp.sources.snippets',
          score_offset = 85, -- the higher the number, the higher the priority
          -- Only show snippets if I type the trigger_text characters, so
          -- to expand the "bash" snippet, if the trigger_text is ";" I have to
          should_show_items = function()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
            -- NOTE: remember that `trigger_text` is modified at the top of the file
            return before_cursor:match(trigger_text .. '%w*$') ~= nil
          end,
          -- After accepting the completion, delete the trigger_text characters
          -- from the final inserted text
          -- Modified transform_items function based on suggestion by `synic` so
          -- that the luasnip source is not reloaded after each transformation
          -- https://github.com/linkarzu/dotfiles-latest/discussions/7#discussion-7849902
          -- NOTE: I also tried to add the ";" prefix to all of the snippets loaded from
          -- friendly-snippets in the luasnip.lua file, but I was unable to do
          -- so, so I still have to use the transform_items here
          -- This removes the ";" only for the friendly-snippets snippets
          transform_items = function(_, items)
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)
            local start_pos, end_pos = before_cursor:find(trigger_text .. '[^' .. trigger_text .. ']*$')
            if start_pos then
              for _, item in ipairs(items) do
                if not item.trigger_text_modified then
                  ---@diagnostic disable-next-line: inject-field
                  item.trigger_text_modified = true
                  item.textEdit = {
                    newText = item.insertText or item.label,
                    range = {
                      start = { line = vim.fn.line('.') - 1, character = start_pos - 1 },
                      ['end'] = { line = vim.fn.line('.') - 1, character = end_pos },
                    },
                  }
                end
              end
            end
            return items
          end,
        },
        -- Example on how to configure dadbod found in the main repo
        -- https://github.com/kristijanhusak/vim-dadbod-completion
        dadbod = {
          name = 'Dadbod',
          module = 'vim_dadbod_completion.blink',
          min_keyword_length = 2,
          score_offset = 85, -- the higher the number, the higher the priority
        },
        -- https://github.com/moyiz/blink-emoji.nvim
        emoji = {
          module = 'blink-emoji',
          name = 'Emoji',
          score_offset = 93, -- the higher the number, the higher the priority
          min_keyword_length = 2,
          opts = { insert = true }, -- Insert emoji (default) or complete its name
        },
        -- NOTE: For the word definitions make sure wordnet is installed
        dictionary = {
          module = 'blink-cmp-dictionary',
          name = 'Dict',
          score_offset = 20, -- the higher the number, the higher the priority
          enabled = true, -- TODO: turn off if leads to problems
          max_items = 8,
          min_keyword_length = 3,
          opts = {
            dictionary_directories = vim.env.ONEXCLOUD .. '/storage/dictionaries',
            dictionary_files = {
              vim.fn.stdpath('config') .. '/spell/en.utf-8.add',
              vim.fn.stdpath('config') .. '/spell/es.utf-8.add',
            },
          },
        },
      },
    })

    opts.cmdline = {
      enabled = true,
    }

    opts.completion = {
      ghost_text = {
        enabled = true,
        show_without_selection = true,
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      keyword = {
        range = 'full',
      },
      menu = {
        border = 'single',
      },
      documentation = {
        auto_show = true,
        window = {
          border = 'single',
        },
      },
    }
    opts.snippets = {
      preset = 'luasnip', -- Choose LuaSnip as the snippet engine
    }

    opts.keymap = {
      preset = 'default',
      -- accept suggestions
      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        'snippet_forward',
        'fallback',
      },
      -- snippet forward/backward
      ['<S-n>'] = { 'snippet_forward', 'fallback' },
      ['<S-p>'] = { 'snippet_backward', 'fallback' },
      -- select next/prev
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      -- scroll up/down
      ['<S-k>'] = { 'scroll_documentation_up', 'fallback' },
      ['<S-j>'] = { 'scroll_documentation_down', 'fallback' },
      -- show/hide documentation
      ['g?'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
    }

    return opts
  end,
}
