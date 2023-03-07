local M = {}

function M.packages(use)
  use 'nvim-lualine/lualine.nvim'
  use 'nvim-tree/nvim-web-devicons'
end

function M.config()
  require('lualine').setup{
    options = { theme = 'auto' },
    sections = {
      lualine_a = {
        { 'mode', fmt = function(str) return str:sub(1,1) end },
      },
      lualine_b = {'diff'},

      lualine_c = {{'filename', path = 1}},
      lualine_x = {
        'diagnostics',
        'encoding',
        'fileformat',
        'filetype',
      },
      lualine_y = {'progress'},
      lualine_z = {'location'},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {{'filename', path = 1}},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {},
    },
    extensions = {'fzf'},
  }
end

return M
