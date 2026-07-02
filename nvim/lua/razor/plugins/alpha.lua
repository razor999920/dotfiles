return {
  -- Greeter
  'goolord/alpha-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'
    -- require'alpha'.setup(require'alpha.themes.startify'.config)

    -- Header
    -- https://arc.net/l/quote/xgtmjwmc
    dashboard.section.header.val = {
      '██████╗  █████╗ ███████╗ ██████╗ ██████╗',
      '██╔══██╗██╔══██╗╚══███╔╝██╔═══██╗██╔══██╗',
      '██████╔╝███████║  ███╔╝ ██║   ██║██████╔╝',
      '██╔══██╗██╔══██║ ███╔╝  ██║   ██║██╔══██╗',
      '██║  ██║██║  ██║███████╗╚██████╔╝██║  ██║',
      '╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝',
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button('e', '  > New File', '<cmd>ene<CR>'),
      dashboard.button('-', '  > File explorer (Oil)', '<cmd>Oil<CR>'),
      dashboard.button('SPC ff', '󰱼 > Find File', '<cmd>Telescope find_files<CR>'),
      dashboard.button('SPC fs', '  > Find Word', '<cmd>Telescope live_grep<CR>'),
      dashboard.button('q', ' > Quit NVIM', '<cmd>qa<CR>'),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
  end,
}
