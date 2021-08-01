local config = require('utils').Config:new()
local Package = require('utils').Package
local set = vim.api.nvim_set_var

config.packages = {
  Package:new{'https://github.com/Twinside/vim-syntax-haskell-cabal.git'},
  Package:new{'https://github.com/pbrisbin/vim-syntax-shakespeare.git'},
  Package:new{'https://github.com/alx741/vim-yesod.git'},
  Package:new{
    'https://github.com/alx741/vim-hindent.git',
    config = function()
      set('hindent_on_save', 1)
      set('hindent_indent_size', 4)
      set('hindent_line_length', 100)
    end,
  },
}

return config
