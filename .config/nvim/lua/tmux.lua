local config = require('utils').Config:new()
local Package = require('utils').Package
local set = vim.api.nvim_set_var

config.packages = {
  Package:new{'https://github.com/tpope/vim-tbone.git'}, --  " tmux integration},
  Package:new{'https://github.com/jpalardy/vim-slime.git', config = function()
    set('slime_target', 'tmux')
    set('slime_no_mappings', 1)
  end},
}

return config
