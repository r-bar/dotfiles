---@type ConfigPkg
local M = {}

function M.packages(use)
  use {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'kristijanhusak/vim-dadbod-completion',
      'tpope/vim-dadbod',
    },
    ft = { "sql" },
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
    'tpope/vim-dadbod',
    cmd = { 'DB' },
    ft = { 'sql' },
    dependencies = { 'kristijanhusak/vim-dadbod-completion' },
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
    cmd = {
      "IronRepl",
      "IronReplHere",
      "IronRestart",
      "IronSend",
      "IronFocus",
      "IronWatchCurrentFile",
      "IronUnwatchCurrentFile",
    },
  }
  use {
    'https://github.com/sindrets/diffview.nvim.git',
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
  }
end

-- see lsp.lua for

return M
