-- todo-comments.nvim — highlights TODO / FIX / HACK / NOTE / WARN comments and
-- makes them navigable and searchable.
--   ]t / [t       jump to next / previous todo
--   <leader>st    search todos (Telescope)
--   <leader>xt    todos in the Trouble list
return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  keys = {
    { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' },
    { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
    { '<leader>st', '<cmd>TodoTelescope<cr>', desc = '[S]earch [T]odos' },
    { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todos (Trouble)' },
  },
}
