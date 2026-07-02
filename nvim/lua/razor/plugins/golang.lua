return {
  'ray-x/go.nvim',
  dependencies = { -- optional packages
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'leoluz/nvim-dap-go',
    'rcarriga/nvim-notify',
  },
  config = function()
    vim.notify = require 'notify'
    require('go').setup {
      -- gopls is owned by lsp/lspconfig.lua (+ mason-lspconfig auto-enable).
      -- lsp_cfg = false stops go.nvim from spawning a second gopls client while
      -- keeping its :Go* commands, DAP, and tooling.
      lsp_cfg = false,
      luasnip = true,
      trouble = true,
    }
  end,
  event = { 'CmdlineEnter' },
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()',
}
