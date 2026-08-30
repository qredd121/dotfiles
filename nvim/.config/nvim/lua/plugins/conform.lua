require('conform').setup({
  formatters_by_ft = {
    python = { 'ruff_format' },
    lua = { 'stylua' },
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.py', '*.lua' },
  callback = function(args)
    require('conform').format({ bufnr = args.buf })
  end,
})
