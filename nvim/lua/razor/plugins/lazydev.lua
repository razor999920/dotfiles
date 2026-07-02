-- lazydev.nvim — the maintained successor to the (archived) neodev.nvim.
-- Configures lua_ls on the fly with type defs for the Neovim API and your
-- installed plugins, so `vim.*` and plugin modules complete correctly in your
-- config. Loads only when editing Lua.
return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      -- Load luvit (vim.uv) types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  },
}
