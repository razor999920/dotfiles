-- Searchable dev cheatsheet (nvim keymaps + tmux + vim shortcuts).
-- Three front-ends over the same data (lua/razor/cheatsheet_data.lua):
--
--   <leader>ch  / :Cheatsheet       floating markdown reader (browse; / search, q close)
--   <leader>cf  / :CheatsheetFind   Telescope fuzzy picker (⏎ copies the keys)
--                :CheatsheetWeb      open cheatsheet.html in the system browser
--
-- To edit entries, change cheatsheet.html then regenerate cheatsheet_data.lua.
-- Local pseudo-plugin: nothing to clone, lazy-loaded on first command/key.
return {
  dir = vim.fn.stdpath 'config', -- local spec: points at an existing dir
  name = 'cheatsheet',
  cmd = { 'Cheatsheet', 'CheatsheetFind', 'CheatsheetWeb' },
  keys = {
    { '<leader>ch', '<cmd>Cheatsheet<CR>', desc = 'Cheatsheet: reader' },
    { '<leader>cf', '<cmd>CheatsheetFind<CR>', desc = 'Cheatsheet: fuzzy find' },
  },
  config = function()
    local cs = require 'razor.cheatsheet'
    vim.api.nvim_create_user_command('Cheatsheet', cs.float, { desc = 'Open the cheatsheet reader' })
    vim.api.nvim_create_user_command('CheatsheetFind', cs.telescope, { desc = 'Fuzzy-search the cheatsheet' })
    vim.api.nvim_create_user_command('CheatsheetWeb', cs.web, { desc = 'Open the cheatsheet in the browser' })
  end,
}
