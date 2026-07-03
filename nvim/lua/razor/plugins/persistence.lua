-- persistence.nvim: auto-saves a session per working directory so nvim remembers
-- your open buffers/layout. Restore it from the dashboard or with these maps.
--   <leader>ps  restore the session for the current directory
--   <leader>pl  restore the last session (any directory)
--   <leader>pd  stop saving the current session (don't persist this one)
-- Tip: run these from the greeter (before opening a file) to pick up where you left off.
return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {},
  keys = {
    {
      '<leader>ps',
      function()
        require('persistence').load()
      end,
      desc = 'Session: restore (this dir)',
    },
    {
      '<leader>pl',
      function()
        require('persistence').load { last = true }
      end,
      desc = 'Session: restore last',
    },
    {
      '<leader>pd',
      function()
        require('persistence').stop()
      end,
      desc = "Session: don't save this one",
    },
  },
}
