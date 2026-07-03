return {
  -- Greeter / dashboard
  'goolord/alpha-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    ------------------------------------------------------------------
    -- Colors: pulled live from the catppuccin palette so this adapts
    -- to mocha/latte and honours color_overrides in colorscheme.lua.
    ------------------------------------------------------------------
    local function palette()
      local ok, cp = pcall(require, 'catppuccin.palettes')
      local flavour = (vim.o.background == 'light') and 'latte' or 'mocha'
      if ok then
        local p = cp.get_palette(flavour)
        if p then
          return p
        end
      end
      return { -- fallback (mocha overrides)
        green = '#a9b665',
        surface1 = '#404040',
        subtext0 = '#bdae93',
        overlay1 = '#928374',
        overlay0 = '#595959',
        text = '#ebdbb2',
      }
    end

    local function blend(a, b, t)
      local function h(s, i)
        return tonumber(s:sub(i, i + 1), 16)
      end
      local ar, ag, ab = h(a, 2), h(a, 4), h(a, 6)
      local br, bg, bb = h(b, 2), h(b, 4), h(b, 6)
      return string.format('#%02x%02x%02x', ar + (br - ar) * t, ag + (bg - ag) * t, ab + (bb - ab) * t)
    end

    local WORD = '#744577' -- RAZOR wordmark colour
    local MENU = '#84C5B1' -- menu icons + shortcut keys (distinct from the word)

    local function set_hl()
      local c = palette()
      local hl = vim.api.nvim_set_hl
      for i = 1, 5 do -- solid colour across all letters
        hl(0, 'LetterGrad' .. i, { fg = WORD, bold = true })
      end
      hl(0, 'AlphaOnline', { fg = c.green, bold = true }) -- green status dot + label
      hl(0, 'AlphaSubtle', { fg = c.overlay1 })
      hl(0, 'AlphaSubtitle', { fg = c.subtext0, italic = true })
      hl(0, 'AlphaButtons', { fg = c.text })
      hl(0, 'AlphaIcon', { fg = MENU }) -- menu icons (accent)
      hl(0, 'AlphaShortcut', { fg = MENU, bold = true }) -- shortcut keys (accent)
      hl(0, 'AlphaFooter', { fg = c.overlay0, italic = true })
    end
    set_hl()

    ------------------------------------------------------------------
    -- Header: RAZOR wordmark, coloured left-to-right with the gradient.
    ------------------------------------------------------------------
    -- stylua: ignore start
    local R = { [[██████╗ ]], [[██╔══██╗]], [[██████╔╝]], [[██╔══██╗]], [[██║  ██║]], [[╚═╝  ╚═╝]] }
    local A = { [[ █████╗ ]], [[██╔══██╗]], [[███████║]], [[██╔══██║]], [[██║  ██║]], [[╚═╝  ╚═╝]] }
    local Z = { [[███████╗]], [[╚══███╔╝]], [[  ███╔╝ ]], [[ ███╔╝  ]], [[███████╗]], [[╚══════╝]] }
    local O = { [[ ██████╗ ]], [[██╔═══██╗]], [[██║   ██║]], [[██║   ██║]], [[╚██████╔╝]], [[ ╚═════╝ ]] }
    -- stylua: ignore end

    local letters = { R, A, Z, O, R }
    local header_val, header_hl = {}, {}
    for i = 1, 6 do
      local line, ranges = '', {}
      for li, L in ipairs(letters) do
        local start = #line
        line = line .. L[i]
        ranges[#ranges + 1] = { 'LetterGrad' .. li, start, #line }
      end
      header_val[i] = line
      header_hl[i] = ranges
    end
    dashboard.section.header.val = header_val
    dashboard.section.header.opts.hl = header_hl

    ------------------------------------------------------------------
    -- Info rows: quote, date, and an "online" status badge
    ------------------------------------------------------------------
    local quotes = {
      'The grind never stops.',
      "Hard work beats talent when talent doesn't work hard.",
      'Success is small efforts repeated day in and day out.',
      'There are no shortcuts. Only the grind.',
      "Dreams don't work unless you do.",
      'The harder you work, the luckier you get.',
      "Discipline is doing it even when you don't feel like it.",
    }
    local quote = quotes[(os.time() % #quotes) + 1]

    local subtitle = {
      type = 'text',
      val = '“' .. quote .. '”',
      opts = { position = 'center', hl = 'AlphaSubtitle' },
    }
    local dateline = {
      type = 'text',
      val = os.date '%A, %d %b %Y',
      opts = { position = 'center', hl = 'AlphaSubtle' },
    }

    -- Simple green status: dot + label.
    local status = {
      type = 'text',
      val = '● online',
      opts = { position = 'center', hl = 'AlphaOnline' },
    }

    ------------------------------------------------------------------
    -- Buttons
    ------------------------------------------------------------------
    local function button(sc, icon, txt, cmd)
      local b = dashboard.button(sc, icon .. '  ' .. txt, cmd)
      b.opts.hl = { { 'AlphaIcon', 0, #icon + 2 }, { 'AlphaButtons', #icon + 2, -1 } }
      b.opts.hl_shortcut = 'AlphaShortcut'
      b.opts.width = 42
      return b
    end

    -- CHANGED: trimmed the dashboard to the actions actually used at startup.
    -- Removed 'New file' (you open existing files) and 'Mason' (opened rarely,
    -- not from the greeter). Added 'Cheatsheet' showing its real <leader>ch map.
    dashboard.section.buttons.val = {
      button('f', '', 'Find file', '<cmd>Telescope find_files<CR>'),
      button('r', '', 'Recent files', '<cmd>Telescope oldfiles<CR>'),
      button('w', '', 'Find word', '<cmd>Telescope live_grep<CR>'),
      button('-', '', 'File explorer', '<cmd>Oil<CR>'),
      button('SPC ch', '', 'Cheatsheet', '<cmd>Cheatsheet<CR>'),
      button('c', '', 'Config', '<cmd>Telescope find_files cwd=' .. vim.fn.stdpath 'config' .. '<CR>'),
      button('l', '󰒲', 'Plugins (Lazy)', '<cmd>Lazy<CR>'),
      button('q', '', 'Quit', '<cmd>qa<CR>'),
    }

    ------------------------------------------------------------------
    -- Footer
    ------------------------------------------------------------------
    local function footer()
      local ok, lazy = pcall(require, 'lazy')
      if not ok then
        return ''
      end
      local stats = lazy.stats()
      local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
      return '⚡ ' .. stats.loaded .. '/' .. stats.count .. ' plugins   ·   ' .. ms .. ' ms'
    end
    dashboard.section.footer.val = footer()
    dashboard.section.footer.opts.hl = 'AlphaFooter'

    ------------------------------------------------------------------
    -- Layout
    ------------------------------------------------------------------
    dashboard.opts.layout = {
      { type = 'padding', val = 3 },
      dashboard.section.header,
      { type = 'padding', val = 1 },
      subtitle,
      dateline,
      { type = 'padding', val = 1 },
      status,
      { type = 'padding', val = 2 },
      dashboard.section.buttons,
      { type = 'padding', val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.opts)

    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyVimStarted',
      callback = function()
        dashboard.section.footer.val = footer()
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        set_hl()
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
