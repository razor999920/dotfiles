return {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    -- import mason
    local mason = require 'mason'

    -- import mason-lspconfig
    local mason_lspconfig = require 'mason-lspconfig'

    local mason_tool_installer = require 'mason-tool-installer'

    local mason_nvim_dap = require 'mason-nvim-dap'

    -- enable mason and configure icons
    mason.setup {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    }

    -- mason-lspconfig v2: `automatic_installation` was removed. Installs come
    -- from `ensure_installed`; enabling is handled by `automatic_enable`
    -- (default true) which calls `vim.lsp.enable()` for every installed server
    -- under its lspconfig name.
    mason_lspconfig.setup {
      -- list of servers for mason to install
      ensure_installed = {
        'eslint',
        'html',
        'cssls',
        'tailwindcss',
        'svelte',
        'lua_ls',
        'gopls',
        'pyright',
        'templ',
      },
    }

    mason_tool_installer.setup {
      ensure_installed = {
        'prettier',
        'stylua',
        'isort',
        'black',
        'pylint',
        'eslint_d',
        'golangci-lint',
        'gofumpt',
        'goimports',
        'typescript-language-server',
        'tailwindcss-language-server',
        'dockerfile-language-server',
        'docker-compose-language-service',
      },
    }

    mason_nvim_dap.setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }
  end,
}
