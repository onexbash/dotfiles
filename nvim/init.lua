-- set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- LOAD MODULES --

-- lazy
require('core.lazy')

-- core
require('core.options')
require('core.autocmd')
require('core.keymaps')
