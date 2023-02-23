local M = {}

function M.packages(use)
  use {
    'folke/tokyonight.nvim',
    enabled = false,
    config = function()
      vim.cmd[[colorscheme tokyonight-night]]
    end,
  }

  use {
    'shaunsingh/nord.nvim',
    enabled = false,
    config = function()
      require('nord').set()
    end,
  }

  use {
    'EdenEast/nightfox.nvim',
    enabled = true,
    config = function()
      require('nightfox').setup({
        options = {
          transparent = true,
        },
      })
      vim.cmd[[colorscheme nightfox]]
    end,
  }
end

return M
