-- nvim-surround: add / change / delete surrounding pairs (quotes, brackets, tags).
-- Uses the plugin's default mappings (no <leader> maps, so nothing here conflicts):
--   ys{motion}{char}  add surround      e.g.  ysiw"   ->  word  becomes  "word"
--   yss{char}         surround the line e.g.  yss)    ->  (whole line)
--   ds{char}          delete surround   e.g.  ds"     ->  "word"  becomes  word
--   cs{old}{new}      change surround   e.g.  cs"'    ->  "word"  becomes  'word'
--   S{char}           in visual mode, surround the selection
return {
  'kylechui/nvim-surround',
  version = '*', -- use a stable tag
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {},
}
