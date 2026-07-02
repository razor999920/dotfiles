# CLAUDE.md — Neovim config guide

Guidance for Claude Code (or any AI agent) working in this Neovim configuration.
Read this before changing plugins, keymaps, or LSP.

## Environment facts (verify, don't assume)

- **Neovim 0.12.x** (nightly/dev channel). "Latest" is a moving target; expect
  occasional churn. Check with `nvim --version`.
- **Plugin manager: lazy.nvim** (`lua/razor/lazy.lua`). Keep it — do **not**
  migrate to `vim.pack`.
- **Native LSP** (0.11+ API): servers are configured with `vim.lsp.config(name, {...})`
  and enabled via mason-lspconfig's `automatic_enable` (see LSP section). We do
  **not** use the old `lspconfig.<server>.setup{}` handler pattern.

## Layout

```
init.lua                     -> requires razor.core, then razor.lazy
lua/razor/
  core/
    options.lua              -> vim.opt settings
    keymaps.lua              -> global keymaps (leader = <space>)
  lazy.lua                   -> bootstraps lazy.nvim, imports razor.plugins + razor.plugins.lsp
  plugins/
    *.lua                    -> one file per plugin (or small group); each returns a lazy spec
    init.lua                 -> a few inline specs (fugitive, tmux-navigator, sleuth, cmp deps)
    lsp/
      lspconfig.lua          -> LSP server settings + LspAttach keymaps
      mason.lua              -> mason + mason-lspconfig + tool-installer + dap installer
```

`routeTree`-style generated files: none. `lazy-lock.json` pins plugin commits —
commit it after intentional updates.

## Conventions

- **Adding a plugin:** create `lua/razor/plugins/<name>.lua` returning a lazy
  spec table. It's auto-imported (the whole `razor.plugins` dir is imported).
  Prefer lazy-loading (`event`, `ft`, `keys`, or `cmd`) over eager load.
- **Keymaps:** global ones live in `core/keymaps.lua`; plugin-specific ones go in
  that plugin's spec (`keys = {}`) or its `config`. Leader is `<space>`.
- **Leader-key namespaces already in use** (check before claiming a new one):
  - `<leader>s*` search/telescope, `<leader>h*` git hunks (gitsigns),
    `<leader>x*` Trouble + todos, `<leader>t{o,x,n,p,f}` tabs,
    `<leader>s{v,h,e,x}` splits, `<leader>c a` code action, `<leader>r{n,s}` rename/restart LSP.
  - `<leader>t` (bare) is intentionally **unmapped** — it would shadow the tab maps.
- **Formatting:** stylua (`.stylua.toml`, 2-space, single-quote). Match existing style.

## LSP (important — this bit has sharp edges)

Two pieces cooperate:

1. **mason-lspconfig v2** (`lsp/mason.lua`) installs servers via `ensure_installed`
   and, with `automatic_enable = true` (its default), calls `vim.lsp.enable()` for
   every installed server **under its lspconfig config name**.
2. **`lsp/lspconfig.lua`** calls `vim.lsp.config('<name>', {...})` to *merge
   settings* onto those servers.

Rules:
- **Use lspconfig config names, NOT mason/binary names.** e.g. `ts_ls` (not
  `typescript-language-server`), `docker_compose_language_service` (not
  `docker-compose-langserver`). A wrong name creates a bare config with **no
  root markers** → the server attaches in single-file mode. Verify a name resolves:
  ```
  nvim --headless "+Lazy load nvim-lspconfig" \
    "+lua print(vim.inspect(vim.lsp.config['ts_ls'] ~= nil))" +qa
  ```
- **gopls is owned solely by `lspconfig.lua`.** `go.nvim` has `lsp_cfg = false`
  so it does not spawn a second gopls client. Don't re-enable go.nvim's LSP.
- `mason-lspconfig`'s `automatic_installation` option was **removed in v2** — don't
  re-add it. Installs come from `ensure_installed`.
- Check reality with `:checkhealth lsp` / `:LspInfo` (shows attached clients + roots).

## Plugin inventory (by area)

- **Completion:** nvim-cmp (+ LuaSnip, cmp-nvim-lsp, cmp-path, cmp_luasnip,
  friendly-snippets). lazydev is a cmp source for Lua.
- **LSP/tools:** nvim-lspconfig, mason + mason-lspconfig + mason-tool-installer,
  fidget, **lazydev.nvim** (Lua nvim-API types; replaced the archived neodev),
  nvim-lsp-file-operations.
- **Treesitter:** nvim-treesitter (**master branch API** — see Pending), nvim-ts-autotag
  (its own `setup()` via `opts={}`), treesitter-textobjects, ts-context-commentstring.
- **Files/nav:** **oil.nvim** (the file explorer — `-` opens parent dir),
  telescope (+ fzf-native), flash.nvim (`s` to jump).
- **Git:** gitsigns, fugitive, rhubarb, lazygit.
- **UI:** catppuccin (active theme, heavily customized) + gruvbox-material (lazy
  alt), lualine, alpha (dashboard), barbecue (winbar), indent-blankline,
  which-key, dressing, trouble (**v3**), todo-comments.
- **Editing:** Comment.nvim, nvim-autopairs.
- **Lang:** go.nvim (Go tooling; LSP disabled), nvim-dap (+ dap-ui, dap-go,
  mason-nvim-dap), conform (format), nvim-lint.
- **Misc:** toggleterm (`<c-t>`), tmux-navigator, vim-sleuth.

## Known gotchas

- **ts-context-commentstring** must have its legacy CursorHold autocmd disabled or
  it crashes on parserless buffers. We set `vim.g.skip_ts_context_commentstring_module
  = true` + `enable_autocmd = false` in `plugins/comment.lua`. Keep that.
- **LuaSnip** builds a `jsregexp` submodule in-place; its clone can drift and block
  `:Lazy sync` ("You have local changes..."). Fix: `x` then `I` in the Lazy UI, or
  `rm -rf ~/.local/share/nvim/lazy/LuaSnip` and `:Lazy install`. Everything under
  `~/.local/share/nvim/lazy/` is a reproducible clone — safe to delete.
- **Trouble is v3**: use `Trouble <mode> toggle` (e.g. `Trouble diagnostics toggle`),
  never the old `TroubleToggle`.
- **catppuccin** carries a large `highlight_overrides` block (incl. now-inert
  `NeoTree*` groups after neo-tree removal — harmless, low priority to prune).

## Pending migrations (do these WITH the user present — they can break the editor)

1. **nvim-treesitter `master` → `main`.** The rewrite removes the module system
   (`require('nvim-treesitter.configs')`, the `highlight`/`indent`/`textobjects`/
   `incremental_selection` tables). Highlighting can break mid-migration. Own session.
2. **nvim-cmp → blink.cmp** (optional). Faster, less config, but touches autopairs
   integration, `cmp_nvim_lsp` capabilities, the lazydev source, and LuaSnip wiring.
3. **snacks.nvim** (optional consolidation). Could replace alpha (dashboard) +
   dressing and add a picker/notifier.

## Verifying a change (fast feedback, no interactive session)

- Syntax check one file: `luajit -bl lua/razor/plugins/<f>.lua >/dev/null && echo ok`
- Load specific plugins headless and assert no error:
  ```
  nvim --headless "+Lazy load <plugin> ..." \
    "+lua vim.defer_fn(function() print(pcall(require,'<mod>') and 'OK' or 'FAIL'); vim.cmd('qa!') end, 600)"
  ```
- Install/update + prune orphans: `nvim --headless "+Lazy! sync" +qa` (blocking).
- Startup profile: `nvim --headless --startuptime /tmp/st.log +qa && tail -1 /tmp/st.log`
- Deprecations / LSP health: `:checkhealth vim.deprecated`, `:checkhealth lsp`.

Config is a git repo — review with `git diff`, revert a file with `git checkout <file>`.
