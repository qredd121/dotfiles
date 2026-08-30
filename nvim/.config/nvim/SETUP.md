# Neovim Config Setup

Neovim 0.12+ configuration. Pure mini.nvim stack, driven by Omarchy themes, zero Mason.

---

## Stack Summary

| Category       | Choice                                                              |
|----------------|---------------------------------------------------------------------|
| Plugin manager | `vim.pack` (built-in, 0.12+)                                        |
| Colorscheme    | `mini.base16` auto-synced from Omarchy `colors.toml`                |
| Fuzzy finder   | `mini.pick`                                                         |
| Completion     | `mini.completion`                                                   |
| File nav       | `mini.files`                                                        |
| Git            | `mini.diff` + `mini.git`                                            |
| Statusline     | `mini.statusline`                                                   |
| Tabline        | `mini.tabline`                                                      |
| Text objects   | `mini.ai`                                                           |
| Surround       | `mini.surround` (`gz` prefix)                                       |
| Autopairs      | `mini.pairs`                                                        |
| Icons          | `mini.icons`                                                        |
| Notifications  | `mini.notify`                                                       |
| Keymap hints   | `mini.clue`                                                         |
| Motions        | `mini.jump` + `mini.jump2d`                                         |
| Indent viz     | `mini.indentscope`                                                  |
| Snippets       | `mini.snippets`                                                     |
| LSP            | `nvim-lspconfig` — `ty`, `ruff`, `lua-language-server`              |
| Formatting     | `conform.nvim` — `ruff-format`, `stylua`                            |
| Treesitter     | `nvim-treesitter` (`main` branch, Nvim 0.12+) — python, lua, bash  |
| Find & Replace | `grug-far.nvim`                                                     |

### Plugin repos

| Plugin           | URL                                                          | Notes |
|------------------|--------------------------------------------------------------|-------|
| `mini.nvim`      | https://github.com/nvim-mini/mini.nvim                       | All mini modules from one repo |
| `nvim-lspconfig` | https://github.com/neovim/nvim-lspconfig                     | |
| `nvim-treesitter`| https://github.com/nvim-treesitter/nvim-treesitter           | Use `main` branch (Nvim 0.12+). Repo archived intentionally — `master` locked for 0.11, `main` is the active rewrite |
| `conform.nvim`   | https://github.com/stevearc/conform.nvim                     | |
| `grug-far.nvim`  | https://github.com/MagicDuck/grug-far.nvim                   | |

---

## Prerequisites

Install system packages. No Mason — all LSP servers and tools come from pacman.

```sh
sudo pacman -S \
  ty \
  ruff \
  lua-language-server \
  stylua \
  ripgrep \
  git \
  tree-sitter-cli \
  wl-clipboard
```

| Package              | Role                                                      |
|----------------------|-----------------------------------------------------------|
| `ty`                 | Python LSP: type checking, completions, go-to-def         |
| `ruff`               | Python LSP: linting + formatting (`ruff server`)          |
| `lua-language-server`| Lua LSP                                                   |
| `stylua`             | Lua formatter (used by conform.nvim)                      |
| `ripgrep`            | Required by grug-far.nvim for search                      |
| `git`                | Required by vim.pack to clone plugins                     |
| `tree-sitter-cli`    | Required by nvim-treesitter `main` branch to compile parsers |
| `wl-clipboard`       | Wayland clipboard support (`clipboard=unnamedplus`)       |

---

## File Structure

```
~/.config/nvim/
  init.lua                  ← entry point: globals + require() calls in order
  nvim-pack-lock.json       ← auto-generated lockfile (commit to dotfiles)
  SETUP.md                  ← this file
  lua/
    options.lua             ← vim.opt settings
    theme.lua               ← colors.toml parser, mini.base16 setup, fs_watch
    plugins.lua             ← vim.pack.add() — plugin declarations only
    keymaps.lua             ← all keymaps
    plugins/
      mini.lua              ← all mini.nvim module setups
      lsp.lua               ← ty, ruff, lua-language-server via vim.lsp.*
      treesitter.lua        ← nvim-treesitter (main branch API)
      conform.lua           ← formatting config
      grugfar.lua           ← grug-far config
```

---

## Config Structure

Grouped-by-concern layout. Each file has exactly one job.

### Philosophy

- `init.lua` — pure entry point. Leader globals + `require()` calls only. No logic.
- `lua/plugins.lua` — **declarative only**. `vim.pack.add()` calls + `PackChanged` hook. No `setup()`.
- `lua/plugins/` — **configuration only**. `require('x').setup({})`. No install declarations.
- `lua/theme.lua` — standalone. Runs after plugins load (mini.nvim must be available). Has its own file watcher logic.
- `lua/options.lua`, `lua/keymaps.lua` — standalone, no plugin deps.

### Load order in init.lua

```lua
vim.g.mapleader = ' '           -- must be before plugins
vim.g.maplocalleader = ','
vim.g.loaded_netrw = 1          -- must be before plugins (disables netrw)
vim.g.loaded_netrwPlugin = 1

require('options')
require('plugins')              -- installs + loads all plugins
require('theme')                -- mini.base16 from colors.toml (needs mini.nvim loaded)
require('plugins.mini')
require('plugins.lsp')
require('plugins.treesitter')
require('plugins.conform')
require('plugins.grugfar')
require('keymaps')              -- last — all plugins guaranteed available
```

### Splitting a file later

- `lua/plugins/mini.lua` → `lua/plugins/mini-ui.lua` + `lua/plugins/mini-editor.lua`
- `lua/plugins/lsp.lua` → per-language files if servers grow

---

## Implementation Phases

Break down for an agent executing this config from scratch.

---

### Phase 1 — Bootstrap & Core

**Goal:** Neovim starts without errors. Plugins install. Colorscheme applies.

Files to write:
- `init.lua` — leader globals, netrw disable, require() chain
- `lua/options.lua` — vim.opt settings
- `lua/plugins.lua` — vim.pack.add() for all 5 plugins + PackChanged hook
- `lua/theme.lua` — colors.toml parser, mini.base16 setup, fs_watch

**Verify:**
- `nvim` opens without errors
- `:messages` is clean
- Colorscheme matches current Omarchy theme
- `:lua vim.pack.get()` shows all 5 plugins active

**Known gotcha — netrw:**
`vim.g.loaded_netrw = 1` and `vim.g.loaded_netrwPlugin = 1` must be set in `init.lua`
**before** any `require()` call. If set later, netrw may already have initialized and
will conflict with mini.files.

---

### Phase 2 — mini.nvim modules

**Goal:** All mini modules set up and working. File picker, completion, git signs visible.

File to write:
- `lua/plugins/mini.lua` — all mini module setups

**Critical details:**

**mini.files — directory interception:**
`use_as_default_explorer` must be `false`. We handle `nvim .` ourselves via a
`BufEnter` autocmd that detects directory buffers and opens `mini.pick` instead:

```lua
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
```

**mini.completion — disable in picker/explorer buffers:**
`mini.completion` fires globally including inside mini.pick and mini.files buffers,
causing a garbled completion popup to appear instead of expected behavior.
Disable it using the official mini.nvim buffer-local variable and events:

```lua
-- disable inside mini.pick
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniPickStart',
  callback = function()
    vim.b[vim.api.nvim_get_current_buf()].minicompletion_disable = true
  end,
})

-- disable inside mini.files
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    vim.b[args.data.buf_id].minicompletion_disable = true
  end,
})
```

**mini.surround — gz prefix:**
Default prefix is `s` which shadows the native `s` (substitute char) operator.
Remap all actions to `gz` prefix:

```lua
require('mini.surround').setup({
  mappings = {
    add = 'gza', delete = 'gzd', replace = 'gzr',
    find = 'gzf', find_left = 'gzF', highlight = 'gzh',
  },
})
```

**Verify:**
- `<Space>f` opens file picker
- `nvim .` opens file picker (not explorer, not garbled list)
- `<Space>e` opens mini.files explorer
- Typing in a normal buffer triggers completion popup
- No completion popup appears inside mini.pick or mini.files

---

### Phase 3 — LSP

**Goal:** ty, ruff, lua-language-server all attach and provide diagnostics.

File to write:
- `lua/plugins/lsp.lua`

**Key details:**
- Use native `vim.lsp.config()` + `vim.lsp.enable()` (0.11+ API). No lspconfig `setup()` calls.
- `ty` command is `{ 'ty', 'server' }` (requires the `server` subcommand)
- `ruff` command is `{ 'ruff', 'server' }` (requires the `server` subcommand)
- `lua_ls` binary is named `lua-language-server` on Arch
- Both `ty` and `ruff` attach to `python` filetypes simultaneously — this is correct and intentional
- Enable `virtual_lines = { current_line = true }` for inline diagnostics

**Verify:**
- Open a `.py` file → `:LspInfo` shows `ty` and `ruff` both attached
- Open `init.lua` → `:LspInfo` shows `lua_ls` attached
- Hover (`K`) shows documentation
- Intentional type error shows diagnostic underline

---

### Phase 4 — Treesitter

**Goal:** Syntax highlighting for python, lua, bash via treesitter.

File to write:
- `lua/plugins/treesitter.lua`

**Key details — nvim-treesitter main branch (breaking change from master):**

The `main` branch is a full rewrite. The old API is completely gone:
```lua
-- OLD (master) — DO NOT USE
require('nvim-treesitter.configs').setup({ highlight = { enable = true } })
```

New API:
```lua
-- Install parsers
require('nvim-treesitter').install({ 'python', 'lua', 'bash' })

-- Enable highlighting per filetype via native vim.treesitter
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'lua', 'bash', 'sh' },
  callback = function() pcall(vim.treesitter.start) end,
})
```

`nvim-treesitter` on `main` provides query files. Neovim itself does the highlighting
via `vim.treesitter.start()`. The plugin no longer owns highlighting.

**System requirement:** `tree-sitter-cli` must be installed (`pacman -S tree-sitter-cli`).

**Verify:**
- `:TSInstallInfo` shows python, lua, bash parsers as installed
- Opening a `.py` file shows syntax highlighting (keywords colored differently from strings)

---

### Phase 5 — Formatting

**Goal:** Format-on-save working for Python and Lua.

File to write:
- `lua/plugins/conform.lua`

**Key details:**
- Python formatter: `ruff_format` (conform's name for `ruff format`)
- Lua formatter: `stylua`
- `lsp_format = "fallback"` means conform tries its formatters first, falls back to LSP if none configured

**Verify:**
- Open a messy `.py` file, save → ruff formats it
- Open a messy `.lua` file, save → stylua formats it

---

### Phase 6 — Keymaps

**Goal:** All keymaps set and working.

File to write:
- `lua/keymaps.lua`

**Key details:**
- Leader/localleader are set in `init.lua`, NOT here
- LSP keymaps `grn`, `grr`, `gri`, `gra` are set automatically by Neovim 0.11+ on LspAttach — do not remap them, just supplement
- `mini.diff` hunk navigation: `goto_hunk('prev')` / `goto_hunk('next')`
- `mini.git` does not use fugitive-style `:Git` commands

---

## Bootstrap

No bootstrap script needed. `vim.pack` is built into Neovim 0.12+.

1. Install system prerequisites (see above)
2. Place config at `~/.config/nvim/`
3. Run `nvim` — vim.pack detects missing plugins and installs them
4. Confirm install: type `:w` in the confirmation buffer, then `:q`
5. Restart Neovim
6. On second start, treesitter parsers install via `PackChanged` hook

If `nvim-pack-lock.json` is committed to dotfiles, all plugins install at exact
locked revisions on a new machine.

---

## Omarchy Theme Integration

The colorscheme is driven entirely by Omarchy. No manual colorscheme management in Neovim.

1. `lua/theme.lua` reads `~/.config/omarchy/current/theme/colors.toml` at startup
2. Maps `color0`–`color15` + `background`/`foreground` to a base16 palette
3. Calls `mini.base16.setup({ palette = ... })`
4. `vim.uv.new_fs_event()` watches `colors.toml` for changes
5. When `omarchy-theme-set <name>` runs, the watcher fires and re-applies instantly

**Color mapping:**
```
base00 = background     base08 = color1  (red)
base01 = color0         base09 = color11 (orange/yellow)
base02 = color8         base0A = color3  (yellow)
base03 = color8         base0B = color2  (green)
base04 = color7         base0C = color6  (cyan)
base05 = foreground     base0D = color4  (blue)
base06 = color15        base0E = color5  (magenta)
base07 = color15        base0F = color13 (bright red)
```

Supported themes: catppuccin, catppuccin-latte, ethereal, everforest, flexoki-light,
gruvbox, hackerman, kanagawa, lumon, matte-black, miasma, nord, osaka-jade, retro-82,
ristretto, rose-pine, tokyo-night, vantablack, white — and any future Omarchy themes.

---

## Options

```lua
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.clipboard      = 'unnamedplus'   -- system clipboard via wl-clipboard
vim.opt.mouse          = 'a'
vim.opt.termguicolors  = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.expandtab      = true
vim.opt.shiftwidth     = 2
vim.opt.tabstop        = 2
vim.opt.softtabstop    = 2
vim.opt.wrap           = false
vim.opt.swapfile       = false
vim.opt.undofile       = true
vim.opt.signcolumn     = 'yes'
vim.opt.updatetime     = 250
vim.opt.splitright     = true
vim.opt.splitbelow     = true
```

---

## Keymaps

`<leader>` = Space. `<localleader>` = `,`.

### Navigation

| Key          | Action                     |
|--------------|----------------------------|
| `<leader>f`  | Find files (mini.pick)     |
| `<leader>g`  | Live grep (mini.pick)      |
| `<leader>b`  | Buffers (mini.pick)        |
| `<leader>e`  | File explorer (mini.files) |
| `<leader>r`  | Find & replace (grug-far)  |

### LSP

| Key   | Action               | Source          |
|-------|----------------------|-----------------|
| `grn` | Rename symbol        | Neovim built-in |
| `grr` | Find references      | Neovim built-in |
| `gri` | Go to implementation | Neovim built-in |
| `gra` | Code action          | Neovim built-in |
| `gd`  | Go to definition     | keymaps.lua     |
| `gD`  | Go to declaration    | keymaps.lua     |
| `K`   | Hover docs           | keymaps.lua     |
| `[d`  | Previous diagnostic  | keymaps.lua     |
| `]d`  | Next diagnostic      | keymaps.lua     |

### Surround (`gz` prefix)

| Key              | Action               | Example                        |
|------------------|----------------------|--------------------------------|
| `gza{motion}{c}` | Add surrounding      | `gzaiw"` → `"word"`           |
| `gzd{c}`         | Delete surrounding   | `gzd"` removes `"`            |
| `gzr{from}{to}`  | Replace surrounding  | `gzr"'` changes `"` to `'`   |
| `gzf{c}`         | Find next surrounding|                                |
| `gzF{c}`         | Find prev surrounding|                                |
| `gzh{c}`         | Highlight surrounding|                                |

### Git

| Key          | Action              |
|--------------|---------------------|
| `[h`         | Previous hunk       |
| `]h`         | Next hunk           |
| `<leader>gs` | Git show at cursor  |
| `<leader>gb` | Git range history   |

### Other

| Key     | Action                  |
|---------|-------------------------|
| `ss`    | Jump2d                  |
| `<Esc>` | Clear search highlight  |

---

## Plugin Management

```
:packupdate              update all (confirm with :w, cancel with :q)
:packupdate!             update all without confirmation
:packupdate <name>       update specific plugin
:packupdate ++lockfile   revert all to lockfile revisions (rollback)
:packdel <name>          remove a plugin (after removing from plugins.lua)
```

`nvim-pack-lock.json` is auto-generated. Commit it to dotfiles for reproducible installs.

---

## Adding a New LSP Server

```sh
sudo pacman -S some-language-server
```

In `lua/plugins/lsp.lua`:
```lua
vim.lsp.config('servername', {
  cmd = { 'binary-name' },
  filetypes = { 'filetype' },
  root_markers = { '.git' },
})
vim.lsp.enable('servername')
```

---

## Adding a New Treesitter Parser

In `lua/plugins/treesitter.lua`, add the language to the install list:
```lua
require('nvim-treesitter').install({ 'python', 'lua', 'bash', 'rust' })
```
And add it to the FileType autocmd pattern. Then run `:TSUpdate`.

---

## Troubleshooting

**Colorscheme not applying:**
- Check `~/.config/omarchy/current/theme/colors.toml` exists
- Run `:lua require('theme').apply()` to manually re-apply

**LSP not starting:**
- `:checkhealth lsp`
- `:!which ty` / `:!which lua-language-server` — confirm binaries are on PATH

**Completion popup appears inside mini.pick or mini.files:**
- Ensure `MiniPickStart` and `MiniFilesBufferCreate` autocmds are set (see Phase 2)
- The variable is `vim.b[buf].minicompletion_disable = true`

**`nvim .` opens wrong thing:**
- Ensure `vim.g.loaded_netrw = 1` is in `init.lua` before any `require()`
- Ensure `mini.files` has `use_as_default_explorer = false`
- Ensure the `BufEnter` + `isdirectory` autocmd is set up in `mini.lua`

**Treesitter highlighting broken:**
- `:TSUpdate` to reinstall parsers
- Ensure `tree-sitter-cli` is installed (`pacman -S tree-sitter-cli`)
- The old `require('nvim-treesitter.configs').setup(...)` API does not exist on `main` branch
