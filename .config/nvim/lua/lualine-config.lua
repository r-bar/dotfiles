local M = {}

M.packages = {
  -- required for lualine
  Package:new{
    'https://github.com/kyazdani42/nvim-web-devicons.git',
    config = function()
      require('nvim-web-devicons').setup{}
    end,
  },
  Package:new{
    'https://github.com/nvim-lualine/lualine.nvim.git',
    config = function()
      require('lualine').setup{
        options = {
          icons_enabled = false,
          --component_separators = { left = '>', right = '<'},
          component_separators = { left = '|', right = '|'},
          --section_separators = { left = '⯈', right = '⯇'},
          --section_separators = { left = '', right = ''},
          --section_separators = { left = '◣', right = '◢'},
          section_separators = { left = '▶', right = '◀'},
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff'},
          lualine_c = {'filename'},
          lualine_x = {'diagnostics'},
          lualine_y = {'encoding', 'fileformat', 'filetype'},
          lualine_z = {'progress', 'location'},
        },
        extensions = {'quickfix', 'fzf'}
      }
    end,
  },
}

return M
