-- Configuration for plugins that provide fullscreen user experiences outside
-- normal text editor functionality

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

  use {
    'folke/trouble.nvim',
    opts = {
      focus = true,
    },
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    }
  }
end

-- see lsp.lua for

return M
