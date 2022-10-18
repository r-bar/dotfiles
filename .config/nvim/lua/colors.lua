local M = {}


local LOAD_ALL = false
local colorscheme = 'tokyonight-night'


local function colormatch(pattern)
  if pattern == nil then error 'cannot match nil pattern' end
  return LOAD_ALL or string.match(pattern, colorscheme)
end

M.packages = {
  Package:new{
    'https://github.com/catppuccin/nvim.git',
    enabled = false,
    as = 'catppuccin',
    config = function()
      local catppuccin = require('catppuccin')
      vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha
      catppuccin.setup{
        transparent_background = false,
        term_colors = false,
        styles = {
          comments = "italic",
          conditionals = "italic",
          loops = "NONE",
          functions = "NONE",
          keywords = "NONE",
          strings = "NONE",
          variables = "NONE",
          numbers = "NONE",
          booleans = "NONE",
          properties = "NONE",
          types = "NONE",
          operators = "NONE",
        },
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = "italic",
              hints = "italic",
              warnings = "italic",
              information = "italic",
            },
            underlines = {
              errors = "underline",
              hints = "underline",
              warnings = "underline",
              information = "underline",
            },
          },
          lsp_trouble = false,
          cmp = true,
          lsp_saga = false,
          gitgutter = false,
          gitsigns = true,
          telescope = true,
          nvimtree = {
            enabled = true,
            show_root = false,
            transparent_panel = false,
          },
          neotree = {
            enabled = false,
            show_root = false,
            transparent_panel = false,
          },
          which_key = false,
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
          },
          dashboard = true,
          neogit = false,
          vim_sneak = false,
          fern = false,
          barbar = false,
          bufferline = true,
          markdown = true,
          lightspeed = false,
          ts_rainbow = false,
          hop = false,
          notify = true,
          telekasten = true,
          symbols_outline = true,
        }
      }
    end,
  },
  Package:new{
    'https://github.com/jacoborus/tender.vim.git',
    enabled = colormatch 'tender',
  },
  Package:new{
    'https://github.com/dfxyz/CandyPaper.vim.git',
    enabled = colormatch 'candy',
  },
  Package:new{
    'https://github.com/christophermca/meta5',
    enabled = colormatch 'meta5',
  },
  Package:new{
    'https://github.com/cocopon/iceberg.vim',
    enabled = colormatch 'iceberg',
    config = function()
      --vim.cmd [[hi! pythonParameters Normal]]
      --vim.cmd [[hi! pythonParameters ctermbg=234 ctermfg=252 guibg=#161821 guifg=#c6c8d1]]
      --vim.cmd [[hi! TSParameter ctermbg=234 ctermfg=252 guibg=#161821 guifg=#c6c8d1]]
      --vim.cmd [[hi! TSParameterReference ctermbg=234 ctermfg=252 guibg=#161821 guifg=#c6c8d1]]
    end,
  },
  Package:new{
    'https://github.com/base16-project/base16-vim.git',
    enabled = colormatch 'base16',
  },
  Package:new{
    'https://github.com/altercation/vim-colors-solarized',
    enabled = colormatch 'solarized',
  },
  Package:new{
    'https://github.com/mhartington/oceanic-next.git',
    enabled = colormatch 'OceanicNext',
  },
  Package:new{
    'https://github.com/tyrannicaltoucan/vim-deep-space.git',
    enabled = colormatch 'deep-space',
  },
  Package:new{
    'https://github.com/jonathanfilip/vim-lucius.git',
    enabled = colormatch 'lucius',
  },
  Package:new{
    'chuling/equinusocio-material.vim',
    config = function() vim.api.nvim_set_var('equinusocio_material_style', 'darker') end,
    enabled = colormatch 'equinusocio',
  },
  Package:new{
    'https://github.com/tomasiser/vim-code-dark.git',
    enabled = colormatch 'codedark',
  },
  Package:new{
    'https://github.com/Th3Whit3Wolf/one-nvim.git',
    enabled = colormatch 'one-nvim',
  },
  Package:new{
    'https://github.com/whatyouhide/vim-gotham.git',
    enabled = colormatch 'gotham',
  },
  Package:new{
    'https://github.com/Domeee/mosel.nvim.git',
    enabled = colormatch 'mosel',
  },
  Package:new{
    'https://github.com/sonph/onehalf.git',
    enabled = colormatch 'onehalf',
    rtp = 'vim/',
  },
  Package:new{
    'https://github.com/arcticicestudio/nord-vim.git',
    enabled = colormatch 'nord',
  },
  Package:new{
    'https://github.com/ayu-theme/ayu-vim.git',
    enabled = colormatch 'ayu',
    config = function()
      -- one of 'dark', 'light', 'mirage'
      vim.g.ayucolor = 'dark'
    end
  },
  Package:new{
    'https://github.com/rose-pine/neovim.git',
    enabled = colormatch 'rose-pine',
    as = 'rose-pine',
    tag = 'v1.*',
  },
  Package:new{
    'https://github.com/EdenEast/nightfox.nvim.git',
    enabled = true,
    config = function()
      -- There is no need to call setup if you don't want to change the default options and settings.
      require('nightfox').setup({
        -- Default options
        --options = {
        --  -- Compiled file's destination location
        --  compile_path = vim.fn.stdpath("cache") .. "/nightfox",
        --  compile_file_suffix = "_compiled", -- Compiled file suffix
        --  transparent = false,    -- Disable setting background
        --  terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
        --  dim_inactive = false,   -- Non focused panes set to alternative background
        --  styles = {              -- Style to be applied to different syntax groups
        --    comments = "NONE",    -- Value is any valid attr-list value `:help attr-list`
        --    conditionals = "NONE",
        --    constants = "NONE",
        --    functions = "NONE",
        --    keywords = "NONE",
        --    numbers = "NONE",
        --    operators = "NONE",
        --    strings = "NONE",
        --    types = "NONE",
        --    variables = "NONE",
        --  },
        --  inverse = {             -- Inverse highlight for different types
        --    match_paren = false,
        --    visual = false,
        --    search = false,
        --  },
        --  modules = {             -- List of various plugins and additional options
        --    -- ...
        --  },
        --}
        options = {
          dim_inactive = true,
          terminal_colors = true,
        },
      })
    end,
  },
  Package:new{
    'https://github.com/folke/tokyonight.nvim.git',
    enabled = true,
    config = function()
      require("tokyonight").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        light_style = "day", -- The theme is used when the background is set to light
        transparent = false, -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "dark", -- style for sidebars, see below
          floats = "dark", -- style for floating windows
        },
        sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
        day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
        hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
        dim_inactive = false, -- dims inactive windows
        lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

        --- You can override specific color groups to use other groups or a hex color
        --- function will be called with a ColorScheme table
        ---@param colors ColorScheme
        --on_colors = function(colors) end,

        --- You can override specific highlights to use other groups or a hex color
        --- function will be called with a Highlights and ColorScheme table
        ---@param highlights Highlights
        ---@param colors ColorScheme
        --on_highlights = function(highlights, colors) end,
      })
    end,
  },
}

function M.background_disable()
  vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
  vim.g.clear_background = 1
end

function M.background_enable()
  vim.cmd('colorscheme ' .. colorscheme)
  vim.g.clear_background = 0
end

function M.background_toggle()
  if vim.g.clear_background == 0 then
    M.background_disable()
  else
    M.background_enable()
  end
end

function M.config()
  vim.cmd[[
    syntax enable
    filetype indent plugin on

    if &term =~ '256color'
      " disable Background Color Erase (BCE) so that color schemes
      " render properly when inside 256-color tmux and GNU screen.
      " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
      set t_ut=
    endif
  ]]

  -- force rendering in 256 color mode
  vim.api.nvim_set_option('t_Co', '256')
  vim.cmd('colorscheme '..colorscheme)
  M.background_enable()

  vim.cmd('command BackgroundEnable :lua require("colors").background_enable()<Enter>')
  vim.cmd('command BackgroundDisable :lua require("colors").background_disable()<Enter>')
  vim.cmd('command BackgroundToggle :lua require("colors").background_toggle()<Enter>')

  -- draw speed tweaks
  vim.api.nvim_set_option('termguicolors', true)
  vim.api.nvim_set_option('lazyredraw', true)
  vim.api.nvim_set_option('synmaxcol', 300)  -- default: 3000
end

return M
