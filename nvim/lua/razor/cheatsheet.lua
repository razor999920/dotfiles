-- In-editor cheatsheet: browse and search your keymaps without leaving nvim.
--
--   require('razor.cheatsheet').float()      -- floating reader (browse; / to search, q to close)
--   require('razor.cheatsheet').telescope()  -- fuzzy picker w/ preview (<CR> copies the keys)
--   require('razor.cheatsheet').web()         -- open the HTML version in the browser
--
-- Data lives in lua/razor/cheatsheet_data.lua, auto-generated from cheatsheet.html.
local M = {}

local ok_data, data = pcall(require, 'razor.cheatsheet_data')
if not ok_data then
  data = {}
end

local ns = vim.api.nvim_create_namespace 'razor_cheatsheet'

-- Catppuccin-ish palette. Explicit hex so it reads well on any dark background.
local C = {
  crust = '#11111b', -- darker-than-editor float background (makes the border pop)
  border = '#7f849c', -- visible grey border against a dark bg
  title = '#cba6f7', -- mauve
  header = '#89b4fa', -- blue section headers
  key = '#a6e3a1', -- green keycaps
  desc = '#cdd6f4', -- text
  mode = '#6c7086', -- muted mode tag
  warn = '#f38ba8', -- red
  hint = '#9399b2',
}

local function setup_hl()
  local hl = vim.api.nvim_set_hl
  hl(0, 'CheatNormal', { fg = C.desc, bg = C.crust })
  hl(0, 'CheatBorder', { fg = C.border, bg = C.crust })
  hl(0, 'CheatTitle', { fg = C.title, bg = C.crust, bold = true })
  hl(0, 'CheatHeader', { fg = C.header, bold = true })
  hl(0, 'CheatKey', { fg = C.key })
  hl(0, 'CheatDesc', { fg = C.desc })
  hl(0, 'CheatMode', { fg = C.mode, italic = true })
  hl(0, 'CheatWarn', { fg = C.warn, bold = true })
  hl(0, 'CheatHint', { fg = C.hint, italic = true })
end

-- Group the flat list into { {category, rows}, ... } preserving first-seen order.
local function grouped()
  local order, by_cat = {}, {}
  for _, e in ipairs(data) do
    if not by_cat[e.category] then
      by_cat[e.category] = {}
      order[#order + 1] = e.category
    end
    table.insert(by_cat[e.category], e)
  end
  local out = {}
  for _, cat in ipairs(order) do
    out[#out + 1] = { category = cat, rows = by_cat[cat] }
  end
  return out
end

local MODE_LABEL = {
  n = 'normal', i = 'insert', v = 'visual', x = 'visual',
  o = 'op-pending', c = 'cmdline', t = 'terminal', tmux = 'tmux',
}

-- Turn a key string into a friendly "how to press" example (leader -> Space).
local function press_hint(keys)
  local s = keys:gsub('<leader>', 'Space '):gsub('<CR>', ' Enter'):gsub('<Esc>', ' Esc')
  s = s:gsub('C%-', 'Ctrl-'):gsub('[<>]', '')
  return (s:gsub('%s+', ' '):gsub('^%s+', ''))
end

--------------------------------------------------------------------------------
-- Floating reader — simple aligned two columns, colored keys, clear header bars
--------------------------------------------------------------------------------
function M.float()
  setup_hl()
  local lines, hls = {}, {}
  local function add(line, ranges) -- ranges = { {col_start, col_end, group}, ... }
    lines[#lines + 1] = line
    if ranges then
      for _, r in ipairs(ranges) do
        hls[#hls + 1] = { #lines - 1, r[1], r[2], r[3] }
      end
    end
  end

  add('  razor · dev cheatsheet', { { 0, -1, 'CheatTitle' } })
  add('  <leader>cf fuzzy find   ·   / search   ·   q close', { { 0, -1, 'CheatHint' } })
  add ''

  for _, g in ipairs(grouped()) do
    -- consistent key column width within the section (min 12)
    local kw = 12
    for _, e in ipairs(g.rows) do
      kw = math.max(kw, vim.fn.strdisplaywidth(e.keys))
    end
    add('  ▌ ' .. g.category, { { 0, -1, 'CheatHeader' } })
    for _, e in ipairs(g.rows) do
      local keys = e.keys
      local pad = string.rep(' ', kw - vim.fn.strdisplaywidth(keys))
      local prefix = '    ' -- 4-space indent
      local mid = '   ' -- gap between columns
      local line = prefix .. keys .. pad .. mid .. e.desc
      local ranges = {}
      local kstart = #prefix
      ranges[#ranges + 1] = { kstart, kstart + #keys, 'CheatKey' }
      local dstart = #prefix + #keys + #pad + #mid
      ranges[#ranges + 1] = { dstart, #line, 'CheatDesc' }
      if e.mode ~= 'n' then
        local tag = '  · ' .. (MODE_LABEL[e.mode] or e.mode)
        local tstart = #line
        line = line .. tag
        ranges[#ranges + 1] = { tstart, #line, 'CheatMode' }
      end
      if e.warn then
        local tag = '  ⚠'
        local wstart = #line
        line = line .. tag
        ranges[#ranges + 1] = { wstart, #line, 'CheatWarn' }
      end
      add(line, ranges)
    end
    add ''
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  for _, h in ipairs(hls) do
    local line, col_s, col_e, group = h[1], h[2], h[3], h[4]
    local endcol = (col_e == -1) and #lines[line + 1] or col_e
    vim.api.nvim_buf_set_extmark(buf, ns, line, col_s, { end_col = endcol, hl_group = group })
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'

  local width = math.min(94, math.floor(vim.o.columns * 0.85))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.85))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2 - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' cheatsheet ',
    title_pos = 'center',
  })
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].winhighlight = 'Normal:CheatNormal,FloatBorder:CheatBorder,FloatTitle:CheatTitle'

  for _, key in ipairs { 'q', '<Esc>' } do
    vim.keymap.set('n', key, '<cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
  end
end

--------------------------------------------------------------------------------
-- Telescope fuzzy picker with a preview pane (falls back to the reader)
--------------------------------------------------------------------------------
function M.telescope()
  local ok = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope not available — opening the reader instead.', vim.log.levels.WARN)
    return M.float()
  end
  setup_hl()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local previewers = require 'telescope.previewers'

  -- Theme ONLY this picker to match the reader (dark crust panel + grey border),
  -- saving your normal Telescope highlights first and restoring them on close so
  -- your other <leader>s* pickers are unaffected.
  local themed = {
    TelescopeNormal = { fg = C.desc, bg = C.crust },
    TelescopeBorder = { fg = C.border, bg = C.crust },
    TelescopePromptNormal = { fg = C.desc, bg = C.crust },
    TelescopePromptBorder = { fg = C.border, bg = C.crust },
    TelescopeResultsNormal = { fg = C.desc, bg = C.crust },
    TelescopeResultsBorder = { fg = C.border, bg = C.crust },
    TelescopePreviewNormal = { fg = C.desc, bg = C.crust },
    TelescopePreviewBorder = { fg = C.border, bg = C.crust },
    TelescopePromptTitle = { fg = C.crust, bg = C.title, bold = true },
    TelescopeResultsTitle = { fg = C.crust, bg = C.header, bold = true },
    TelescopePreviewTitle = { fg = C.crust, bg = C.key, bold = true },
    TelescopeSelection = { fg = C.desc, bg = '#313244', bold = true },
    TelescopeMatching = { fg = C.key, bold = true },
  }
  local saved = {}
  for group, def in pairs(themed) do
    saved[group] = vim.api.nvim_get_hl(0, { name = group }) -- preserves links
    vim.api.nvim_set_hl(0, group, def)
  end
  local function restore_theme()
    for group, def in pairs(saved) do
      pcall(vim.api.nvim_set_hl, 0, group, def)
    end
  end

  -- rounded corners to match the reader's border
  local rounded = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }

  local previewer = previewers.new_buffer_previewer {
    title = 'Keymap',
    define_preview = function(self, entry)
      local e = entry.value
      local pbuf = self.state.bufnr
      local lines = {
        '',
        '   Keys      ' .. e.keys,
        '   Press     ' .. press_hint(e.keys),
        '',
        '   Action    ' .. e.desc,
        '',
        '   Where     ' .. e.category,
        '   Mode      ' .. (MODE_LABEL[e.mode] or e.mode),
      }
      if e.warn then
        lines[#lines + 1] = ''
        lines[#lines + 1] = '   ⚠ ' .. 'This binding is currently shadowed — see the note.'
      end
      vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, lines)
      -- light highlighting for readability
      vim.api.nvim_buf_set_extmark(pbuf, ns, 1, 3, { end_col = 12, hl_group = 'CheatHint' })
      vim.api.nvim_buf_set_extmark(pbuf, ns, 1, 13, { end_col = #lines[2], hl_group = 'CheatKey' })
      vim.api.nvim_buf_set_extmark(pbuf, ns, 2, 3, { end_col = 12, hl_group = 'CheatHint' })
      vim.api.nvim_buf_set_extmark(pbuf, ns, 4, 3, { end_col = 12, hl_group = 'CheatHint' })
      vim.api.nvim_buf_set_extmark(pbuf, ns, 6, 3, { end_col = 12, hl_group = 'CheatHint' })
      vim.api.nvim_buf_set_extmark(pbuf, ns, 7, 3, { end_col = 12, hl_group = 'CheatHint' })
    end,
  }

  pickers
    .new({}, {
      prompt_title = 'Cheatsheet  (⏎ copies the keys)',
      finder = finders.new_table {
        results = data,
        entry_maker = function(e)
          local short = e.category:gsub('^%w+ · ', '')
          return {
            value = e,
            display = string.format('%-16s  %s', e.keys, e.desc),
            ordinal = e.keys .. ' ' .. e.category .. ' ' .. e.desc .. ' ' .. e.mode,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = previewer,
      borderchars = rounded,
      attach_mappings = function(bufnr)
        -- restore your normal Telescope theme however the picker is closed
        vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
          buffer = bufnr,
          once = true,
          callback = restore_theme,
        })
        actions.select_default:replace(function()
          local sel = action_state.get_selected_entry()
          actions.close(bufnr)
          if sel then
            vim.fn.setreg('+', sel.value.keys)
            vim.fn.setreg('"', sel.value.keys)
            vim.notify('Copied to clipboard: ' .. sel.value.keys)
          end
        end)
        return true
      end,
    })
    :find()
end

--------------------------------------------------------------------------------
-- Open the HTML version in the system browser
--------------------------------------------------------------------------------
function M.web()
  local path = vim.fs.joinpath(vim.fn.stdpath 'config', 'cheatsheet.html')
  if vim.fn.filereadable(path) == 0 then
    vim.notify('cheatsheet.html not found at ' .. path, vim.log.levels.ERROR)
    return
  end
  vim.ui.open(path)
end

return M
