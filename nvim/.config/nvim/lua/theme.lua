local neovim_lua_path = vim.fn.expand('~/.config/omarchy/current/theme/neovim.lua')
local theme_name_path = vim.fn.expand('~/.config/omarchy/current/theme.name')

local M = {}

local function resolve_src(raw)
  if raw:match('^https?://') then return raw end
  return 'https://github.com/' .. raw
end

local function repo_name(src)
  return src:match('/([^/]+)$')
end

local function install_and_load(src, name)
  local full_src = resolve_src(src)
  local plug_name = name or repo_name(full_src)
  vim.pack.add({ { src = full_src, name = plug_name } }, { confirm = false })
end

function M.apply()
  if vim.fn.filereadable(neovim_lua_path) ~= 1 then
    vim.notify('theme: neovim.lua not found at ' .. neovim_lua_path, vim.log.levels.WARN)
    return
  end

  local ok, spec = pcall(dofile, neovim_lua_path)
  if not ok or type(spec) ~= 'table' then
    vim.notify('theme: failed to load neovim.lua: ' .. tostring(spec), vim.log.levels.ERROR)
    return
  end

  local lazyvim_opts = {}
  local plugin_entry = nil

  for _, entry in ipairs(spec) do
    local src = type(entry[1]) == 'string' and entry[1] or ''
    if src:match('LazyVim/LazyVim') then
      lazyvim_opts = entry.opts or {}
    else
      plugin_entry = entry
    end
  end

  if not plugin_entry then
    vim.notify('theme: no plugin entry found in neovim.lua', vim.log.levels.WARN)
    return
  end

  local src = plugin_entry[1]
  local name = plugin_entry.name or repo_name(resolve_src(src))

  local deps = plugin_entry.dependencies or {}
  for _, dep in ipairs(deps) do
    local dep_src = type(dep) == 'string' and dep or dep[1]
    if dep_src and not dep_src:match('LazyVim/LazyVim') then
      install_and_load(dep_src)
    end
  end

  install_and_load(src, name)

  if plugin_entry.config then
    pcall(plugin_entry.config, nil, plugin_entry.opts or {})
  else
    if plugin_entry.opts then
      local mod_name = (name or ''):gsub('%.nvim$', '')
      local mod_ok, mod = pcall(require, mod_name)
      if mod_ok and type(mod.setup) == 'function' then
        pcall(mod.setup, plugin_entry.opts)
      end
    end

    if lazyvim_opts.background == 'light' or lazyvim_opts.background == 'dark' then
      vim.o.background = lazyvim_opts.background
    end

    if lazyvim_opts.colorscheme then
      pcall(vim.cmd.colorscheme, lazyvim_opts.colorscheme)
    end
  end
end

local watcher
local function setup_watcher()
  if watcher then
    watcher:stop()
    watcher:close()
  end

  watcher = vim.uv.new_fs_event()
  if not watcher then return end

  watcher:start(theme_name_path, {}, vim.schedule_wrap(function()
    vim.defer_fn(M.apply, 100)
  end))
end

M.apply()

if vim.fn.filereadable(theme_name_path) == 1 then
  setup_watcher()
end

return M
