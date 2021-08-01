local config = require('utils').Config:new()
local Package = require('utils').Package
local set = vim.api.nvim_set_var

config.packages = {
  Package:new{'https://github.com/vim-airline/vim-airline'},
  Package:new{'https://github.com/vim-airline/vim-airline-themes.git'},
}

function config.config()

set('airline_theme', 'iceberg')

vim.api.nvim_set_option('laststatus', 2)

set('airline_left_sep', '▶')
set('airline_left_alt_sep', '>')
set('airline_right_sep', '◀')
set('airline_right_alt_sep', '<')
--set('airline_symbols.linenr', '␊')
--set('airline_symbols.linenr', '␤')
set('airline_symbols.linenr', '¶')
set('airline_symbols.branch', '⎇ ')
--set('airline_symbols.paste', 'ρ')
--set('airline_symbols.paste', 'Þ')
--set('airline_symbols.paste', '∥')
--set('airline_symbols.whitespace', 'Ξ')
set('airline#extensions#branch#enabled', 1)
set('airline#extensions#tagbar#enabled', 0)
set('airline#extensions#languageclient#enabled', 1)
--set('airline#extensions#syntastic#enabled', 1)
set('airline_powerline_fonts', 1)
set('airline_detect_whitespace', 1)
set(
  'airline#extensions#default#section_truncate_width',
  {
    b = 130,
    x = 100,
    y = 100,
    z = 45,
    warning = 60,
    ['error'] = 60,
  }
)

vim.api.nvim_set_option('cmdheight', 2)
end

return config
