-- grug-far.nvim: project-wide find & replace in a dedicated buffer (uses ripgrep).
-- The modern replacement for nvim-spectre; pairs with your heavy Telescope grep use.
-- Lives under a free lowercase <leader>f prefix ("find & replace"):
--   <leader>fr  open find & replace (type a pattern, edit replacement, apply)
--   <leader>fw  open it pre-filled with the word under the cursor
-- Inside the buffer, edit the Search/Replace/Files fields, then apply with the
-- keybinding shown in its header (default <localleader>r). `g?` lists actions.
return {
  'MagicDuck/grug-far.nvim',
  cmd = 'GrugFar',
  keys = {
    {
      '<leader>fr',
      function()
        require('grug-far').open()
      end,
      desc = 'Find & replace (project)',
    },
    {
      '<leader>fw',
      function()
        require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } }
      end,
      desc = 'Find & replace word under cursor',
    },
  },
  opts = {},
}
