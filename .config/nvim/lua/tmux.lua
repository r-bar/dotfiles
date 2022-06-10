local M = {}
local set = vim.api.nvim_set_var

M.packages = {
  Package:new{'https://github.com/tpope/vim-tbone.git'}, --  " tmux integration},
  Package:new{'https://github.com/jpalardy/vim-slime.git', config = function()
    set('slime_target', 'tmux')
    set('slime_no_mappings', 1)
  end},
}

return M
