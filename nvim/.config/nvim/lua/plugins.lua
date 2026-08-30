vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/MagicDuck/grug-far.nvim' },
})

local group = vim.api.nvim_create_augroup('pack_changed', { clear = true })

vim.api.nvim_create_autocmd('User', {
  pattern = 'PackChanged',
  group = group,
  callback = function()
    vim.schedule(function()
      pcall(function()
        require('nvim-treesitter').install({ 'python', 'lua', 'bash' })
      end)
    end)
  end,
})
