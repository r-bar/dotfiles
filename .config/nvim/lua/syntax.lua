-- Module for simple syntax addons. Packages requiring their own complicated
-- config should get their own module

local config = require('utils').Config:new()
local Package = require('utils').Package

config.packages = {
  --Package:new{'https://github.com/sheerun/vim-polyglot.git'},
  Package:new{'https://github.com/coddingtonbear/confluencewiki.vim'},
  Package:new{'https://github.com/towolf/vim-helm.git'},
  Package:new{'https://github.com/google/vim-jsonnet.git'},
  Package:new{'https://github.com/r-bar/ebnf.vim.git'},
}

return config
