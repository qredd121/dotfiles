require('mini.icons').setup()

require('mini.notify').setup()

require('mini.pairs').setup()

require('mini.ai').setup()

require('mini.surround').setup({
  mappings = {
    add = 'gza', delete = 'gzd', replace = 'gzr',
    find = 'gzf', find_left = 'gzF', highlight = 'gzh',
  },
})

require('mini.completion').setup({
  windows = {
    info = { border = 'rounded' },
    signature = { border = 'rounded' },
  },
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniPickStart',
  callback = function()
    vim.b[vim.api.nvim_get_current_buf()].minicompletion_disable = true
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    vim.b[args.data.buf_id].minicompletion_disable = true
  end,
})

require('mini.pick').setup({
  options = { use_cache = true },
  window = {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        relative = 'editor',
        anchor = 'NW',
        height = height,
        width = width,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
      }
    end,
  },
})

require('mini.files').setup({
  options = { use_as_default_explorer = false },
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('dir_open_pick', { clear = true }),
  callback = function(args)
    if vim.api.nvim_get_current_buf() ~= args.buf then return end
    local path = vim.api.nvim_buf_get_name(args.buf)
    if vim.fn.isdirectory(path) ~= 1 then return end
    vim.bo[args.buf].bufhidden = 'wipe'
    vim.schedule(function()
      vim.fn.chdir(path)
      MiniPick.builtin.files({}, { source = { cwd = path } })
    end)
  end,
})

require('mini.jump').setup()
require('mini.jump2d').setup()

require('mini.indentscope').setup()

require('mini.statusline').setup()
require('mini.tabline').setup()

require('mini.diff').setup()
require('mini.git').setup()

require('mini.clue').setup({
  window = {
    delay = 0,
  },
  triggers = {
    { mode = 'n', keys = '<leader>' },
    { mode = 'x', keys = '<leader>' },
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },
  clues = {
    { mode = 'n', keys = '<leader>f', desc = 'Find files' },
    { mode = 'n', keys = '<leader>g', desc = 'Live grep' },
    { mode = 'n', keys = '<leader>b', desc = 'Buffers' },
    { mode = 'n', keys = '<leader>e', desc = 'File explorer' },
    { mode = 'n', keys = '<leader>r', desc = 'Find & replace' },
    { mode = 'n', keys = '<leader>gs', desc = 'Git show at cursor' },
    { mode = 'n', keys = '<leader>gb', desc = 'Git range history' },
    { mode = 'n', keys = '<leader>bd', desc = 'Delete buffer' },
    { mode = 'n', keys = '<leader>bD', desc = 'Delete other buffers' },
    { mode = 'n', keys = 'gz', desc = 'Surround' },
    { mode = 'x', keys = 'gz', desc = 'Surround' },
  },
})

require('mini.snippets').setup()
