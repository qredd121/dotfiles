vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('options')
require('plugins')
require('theme')
require('plugins.mini')
require('plugins.lsp')
require('plugins.treesitter')
require('plugins.conform')
require('plugins.grugfar')
require('keymaps')
