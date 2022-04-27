local config = require('utils').Config:new()
local Package = require('utils').Package
local set = vim.api.nvim_set_var

config.packages = {
  --Package:new{
  --  'https://github.com/vim-python/python-syntax.git',
  --  config = function() set('python_highlight_all', 1) end,
  --},
  Package:new{'https://github.com/Vimjas/vim-python-pep8-indent.git'},
  -- provides python text objects (can probably be removed when treesitter works)
  --Package:new{'https://github.com/jeetsukumaran/vim-pythonsense.git'},
  Package:new{'Glench/Vim-Jinja2-Syntax'},
}

return config
