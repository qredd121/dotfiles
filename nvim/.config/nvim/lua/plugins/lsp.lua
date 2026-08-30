vim.lsp.config('ty', {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { '.git', 'pyproject.toml', 'setup.py', 'setup.cfg' },
  settings = {
    ty = {
      configuration = {
        environment = { python = ".venv" }
      }
    }
  },
})

vim.lsp.config('ruff', {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { '.git', 'pyproject.toml', 'setup.py', 'setup.cfg' },
})

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.git', '.luarc.json', '.luarc.jsonc' },
})

vim.lsp.enable({ 'ty', 'ruff', 'lua_ls' })

vim.diagnostic.config({
  virtual_lines = { current_line = true },
})
