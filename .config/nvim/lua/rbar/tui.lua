local M = {}

function M.packages(use)
  use {
    'tpope/vim-dadbod',
    cmd = "DB",
  }
  use {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'kristijanhusak/vim-dadbod-completion',
      'tpope/vim-dadbod',
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIRename",
      "DBUIAddConnection",
      "DBUIRenameConnection",
      "DBUIDeleteConnection",
      "DBUIExecuteQuery",
    },
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_use_nvim_notify = 1
    end
  }
  use {
    'https://github.com/pwntester/octo.nvim.git',
    cmd = 'Octo',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'ibhagwan/fzf-lua',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      picker = "fzf-lua",
    }
  }
  use {
    'Vigemus/iron.nvim',
    tag = "v3.0",
    cmd = "Repl"
  }
end

-- see lsp.lua for 

return M
