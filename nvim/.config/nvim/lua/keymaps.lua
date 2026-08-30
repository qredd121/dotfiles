local map = vim.keymap.set

map('n', '<leader>f', '<cmd>Pick files<CR>', { desc = 'Find files' })
map('n', '<leader>g', '<cmd>Pick grep_live<CR>', { desc = 'Live grep' })
map('n', '<leader>b', '<cmd>Pick buffers<CR>', { desc = 'Buffers' })
map('n', 'H', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', 'L', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>bd', '<cmd>bdelete!<CR>', { desc = 'Delete buffer' })
map('n', '<leader>bD', function()
  local cur = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if bufnr ~= cur and vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end
end, { desc = 'Delete other buffers' })
map('n', '<leader>e', function() require('mini.files').open() end, { desc = 'File explorer' })
map('n', '<leader>r', '<cmd>GrugFar<CR>', { desc = 'Find & replace' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local buf = args.buf
    map('n', 'gd', vim.lsp.buf.definition, { buffer = buf, desc = 'Go to definition' })
    map('n', 'gD', vim.lsp.buf.declaration, { buffer = buf, desc = 'Go to declaration' })
    map('n', 'K', vim.lsp.buf.hover, { buffer = buf, desc = 'Hover docs' })
    map('n', '[d', vim.diagnostic.goto_prev, { buffer = buf, desc = 'Previous diagnostic' })
    map('n', ']d', vim.diagnostic.goto_next, { buffer = buf, desc = 'Next diagnostic' })
  end,
})

map('n', '[h', function() require('mini.diff').goto_hunk('prev') end, { desc = 'Previous hunk' })
map('n', ']h', function() require('mini.diff').goto_hunk('next') end, { desc = 'Next hunk' })
map('n', '<leader>gs', function() require('mini.git').show_at_cursor() end, { desc = 'Git show at cursor' })
map('n', '<leader>gb', function() require('mini.git').range_history() end, { desc = 'Git range history' })

map('n', 'ss', '<cmd>Jump2d<CR>', { desc = 'Jump2d' })
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
