# razor's Neovim config

A personal Neovim setup, originally forked from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
and reorganized into a modular `lua/razor/` layout. Plugins are managed by
[lazy.nvim](https://github.com/folke/lazy.nvim).

> Working on this config with an AI agent? Read [`CLAUDE.md`](./CLAUDE.md) first —
> it documents the LSP wiring, gotchas, and pending migrations in detail.

## Requirements

- **Neovim 0.11+** (this config runs on the 0.12.x nightly and uses the native
  `vim.lsp.config()` / `vim.lsp.enable()` API).
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) and `fd` — required by several Telescope pickers.
- A [Nerd Font](https://www.nerdfonts.com/) and a true-color terminal (iTerm2, WezTerm, Kitty, etc.).
- A C compiler + `git` — for Treesitter parsers and `telescope-fzf-native`.

## Install

```sh
# back up any existing config first
git clone <this-repo> "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim   # lazy.nvim bootstraps and installs everything on first launch
```

Headless install (no UI):

```sh
nvim --headless "+Lazy! sync" +qa
```

## Layout

```
init.lua                  -> requires razor.core, then razor.lazy
lua/razor/
  core/
    options.lua           -> vim.opt settings
    keymaps.lua           -> global keymaps (leader = <space>)
    init.lua              -> loads keymaps + options
  lazy.lua                -> bootstraps lazy.nvim, imports razor.plugins + razor.plugins.lsp
  plugins/
    *.lua                 -> one file per plugin (or small group); each returns a lazy spec
    init.lua              -> a few inline specs (fugitive, tmux-navigator, sleuth, cmp deps)
    lsp/
      lspconfig.lua       -> LSP server settings + LspAttach keymaps
      mason.lua           -> mason + mason-lspconfig + tool/dap installers
lazy-lock.json            -> pinned plugin commits (commit after intentional updates)
```

## Conventions

- **Add a plugin:** create `lua/razor/plugins/<name>.lua` returning a lazy spec table.
  The whole `razor.plugins` directory is auto-imported. Prefer lazy-loading
  (`event` / `ft` / `keys` / `cmd`) over eager load.
- **Keymaps:** global maps live in `core/keymaps.lua`; plugin-specific maps go in
  that plugin's spec. Leader is `<space>`. Namespaces already in use:
  `<leader>s*` search/splits, `<leader>h*` git hunks, `<leader>x*` Trouble/todos,
  `<leader>t{o,x,n,p,f}` tabs, `<leader>c a` code action, `<leader>r{n,s}` rename/restart LSP.
  `<leader>t` (bare) is intentionally unmapped so it doesn't shadow the tab maps.
- **File explorer:** [oil.nvim](https://github.com/stevearc/oil.nvim) — press `-` to
  open the parent directory as an editable buffer.
- **Formatting:** [stylua](https://github.com/JohnnyMorganz/StyLua) (`.stylua.toml`:
  2-space indent, single quotes). Match existing style.

## Highlights

- Native LSP via `mason` + `mason-lspconfig` (auto-enable) with settings merged
  through `vim.lsp.config()`; completion via `nvim-cmp`.
- Treesitter, Telescope (+ fzf-native), flash.nvim, which-key, trouble, todo-comments.
- Git: gitsigns, fugitive, rhubarb, lazygit.
- UI: catppuccin (active theme) + lualine + alpha dashboard.
- Go tooling via go.nvim (its LSP disabled — gopls is owned by `lspconfig.lua`),
  DAP debugging, conform + nvim-lint.

## Verifying changes

```sh
# syntax-check one file
luajit -bl lua/razor/plugins/<file>.lua >/dev/null && echo ok

# install/update + prune orphaned plugins (blocking)
nvim --headless "+Lazy! sync" +qa

# startup profile
nvim --headless --startuptime /tmp/st.log +qa && tail -1 /tmp/st.log
```

The config is a git repo — review changes with `git diff`, revert a file with
`git checkout <file>`.
