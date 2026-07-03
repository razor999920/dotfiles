return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'antosha417/nvim-lsp-file-operations', config = true },
    -- Lua nvim-API/plugin completion is handled by lazydev.nvim (its own spec).
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require 'lspconfig'
    -- import mason_lspconfig plugin
    local mason_lspconfig = require 'mason-lspconfig'
    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'
    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    local keymap = vim.keymap -- for conciseness
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = 'Show LSP references'
        keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts) -- show definition, references

        opts.desc = 'Go to declaration'
        keymap.set('n', 'gD', vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = 'Show LSP definitions'
        keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts) -- show lsp definitions

        opts.desc = 'Show LSP implementations'
        keymap.set('n', 'gI', '<cmd>Telescope lsp_implementations<CR>', opts) -- show lsp implementations

        opts.desc = 'Show LSP type definitions'
        keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', opts) -- show lsp type definitions

        opts.desc = 'See available code actions'
        keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = 'Smart rename'
        keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = 'Show buffer diagnostics'
        keymap.set('n', '<leader>cd', '<cmd>Telescope diagnostics bufnr=0<CR>', opts) -- show  diagnostics for file

        opts.desc = 'Show line diagnostics'
        keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = 'Go to previous diagnostic'
        keymap.set('n', '[d', vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = 'Go to next diagnostic'
        keymap.set('n', ']d', vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = 'Show documentation for what is under cursor'
        keymap.set('n', 'K', vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = 'Restart LSP'
        keymap.set('n', '<leader>rs', ':LspRestart<CR>', opts) -- mapping to restart lsp if necessary
      end,
    })

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = ' ', Warn = ' ', Hint = '󰠠 ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    -- Lua
    vim.lsp.config('lua_ls', {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    })
    vim.lsp.enable 'lua_ls'

    -- Gopls (single source of truth -- go.nvim's own LSP setup is disabled via
    -- lsp_cfg = false so gopls attaches exactly once)
    vim.lsp.config('gopls', {
      capabilities = capabilities,
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
      settings = {
        gopls = {
          gofumpt = true,
          staticcheck = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticTokens = false,
          directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
          codelenses = {
            gc_details = false,
            generate = true,
            regenerate_cgo = true,
            run_govulncheck = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
          analyses = {
            nilness = true,
            unusedparams = true,
            unusedwrite = true,
            useany = true,
          },
        },
      },
    })
    vim.lsp.enable 'gopls'

    -- HTMX
    vim.lsp.config('htmx', {
      capabilities = capabilities,
      filetypes = { 'html', 'templ' }, -- Enable for both HTML and Templ files
    })
    vim.lsp.enable 'htmx'

    -- TEMPL
    vim.lsp.config('templ', {
      capabilities = capabilities,
      filetypes = { 'templ' },
      root_dir = lspconfig.util.root_pattern('go.mod', '.git'),
      cmd = { 'templ', 'lsp' },
      settings = {
        templ = {
          plugins = {
            htmx = true,
          },
          format = {
            enabled = true, -- Enable formatting
            formatter = 'prettier', -- Use prettier for formatting if available
          },
        },
      },
    })
    vim.lsp.enable 'templ'

    -- Typescript (lspconfig config name is `ts_ls`, not the binary name --
    -- using the binary name produced a bare config with no root markers)
    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
      cmd = { 'typescript-language-server', '--stdio' },
    })
    vim.lsp.enable 'ts_ls'

    -- Tailwind
    vim.lsp.config('tailwindcss', {
      capabilities = capabilities,
      filetypes = { 'templ', 'html', 'javascript', 'typescript', 'react', 'typescriptreact' },
      settings = {
        tailwindCSS = {
          includeLanguages = {
            templ = 'html',
          },
          experimental = {
            classRegex = {
              -- Support for HTMX class detection
              'class="([^"]*)"',
              "class='([^']*)'",
            },
          },
        },
      },
    })
    vim.lsp.enable 'tailwindcss'

    -- Docker Compose (lspconfig config name is `docker_compose_language_service`)
    vim.lsp.config('docker_compose_language_service', {
      capabilities = capabilities,
      filetypes = { 'yaml.docker-compose' },
      settings = {
        telemetry = {
          enabled = false,
        },
      },
    })
    vim.lsp.enable 'docker_compose_language_service'

    -- Docker
    vim.lsp.config('dockerls', {
      capabilities = capabilities,
      filetypes = { 'dockerfile' },
      settings = {
        docker = {
          languageserver = {
            diagnostics = {
              enable = true,
            },
            formatter = {
              enable = true,
            },
          },
        },
      },
    })
    vim.lsp.enable 'dockerls'
  end,
}
