require('nvim-treesitter').install({ 'python', 'lua', 'bash' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'lua', 'bash', 'sh' },
  callback = function() pcall(vim.treesitter.start) end,
})
