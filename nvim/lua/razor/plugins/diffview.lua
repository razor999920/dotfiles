-- diffview.nvim: side-by-side git diffs, file history, and a merge-conflict UI.
-- Complements your gitsigns/fugitive/lazygit setup for reviewing branches & PRs.
--   <leader>gd  open the diff view (working tree vs index)
--   <leader>gh  history of the CURRENT file
--   <leader>gl  history of the whole branch (log)
--   <leader>gc  close the diff view
-- Inside the view: <Tab>/<S-Tab> cycle files, `g?` for help, `:DiffviewClose` to exit.
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Diffview: open (working tree)' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'Diffview: current file history' },
    { '<leader>gl', '<cmd>DiffviewFileHistory<CR>', desc = 'Diffview: branch history' },
    { '<leader>gc', '<cmd>DiffviewClose<CR>', desc = 'Diffview: close' },
  },
  opts = {},
}
