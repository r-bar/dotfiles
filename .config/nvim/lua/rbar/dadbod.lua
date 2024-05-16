local M = {}

function M.packages(use)
  use 'tpope/vim-dadbod'
  use {
    'kristijanhusak/vim-dadbod-ui',
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_use_nvim_notify = 1
    end
  }
  use 'kristijanhusak/vim-dadbod-completion'
end

-- see lsp.lua for 

return M
