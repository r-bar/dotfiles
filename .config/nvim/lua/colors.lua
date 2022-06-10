local M = {}


local LOAD_ALL = false
--colorscheme = 'equinusocio_material'
local colorscheme = 'iceberg'


local function colormatch(pattern)
  if pattern == nil then error 'cannot match nil pattern' end
  return LOAD_ALL or string.match(pattern, colorscheme)
end

--function colormatch()
--  return true
--end


M.packages = {
  Package:new{
    'https://github.com/jacoborus/tender.vim.git',
    enabled = colormatch 'tender'
  },
  Package:new{
    'https://github.com/dfxyz/CandyPaper.vim.git',
    enabled = colormatch 'candy',
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
    'https://github.com/christophermca/meta5',
    enabled = colormatch 'meta5',
  },
  Package:new{
    'https://github.com/chriskempson/base16-vim.git',
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
    'https://github.com/rakr/vim-colors-rakr.git',
    enabled = colormatch 'rakr',
  },
  Package:new{
    'chuling/equinusocio-material.vim',
    config = function() vim.api.nvim_set_var('equinusocio_material_style', 'darker') end,
    enabled = colormatch 'equinusocio',
  },
  Package:new{
    'https://github.com/tomasiser/vim-code-dark.git',
    enabled = colormatch 'code-dark',
  },
  Package:new{
    'https://github.com/Th3Whit3Wolf/one-nvim.git',
    enabled = colormatch 'one',
  },
  Package:new{
    'https://github.com/Iron-E/nvim-highlite.git',
    enabled = colormatch 'highlite',
  },
  Package:new{
    'https://github.com/whatyouhide/vim-gotham.git',
    enabled = colormatch 'gotham',
  },
}


function M.config()
  vim.api.nvim_set_option('termguicolors', true)
  -- force rendering in 256 color mode
  vim.api.nvim_set_option('t_Co', '256')
  vim.cmd('colorscheme '..colorscheme)
  vim.cmd [[
  if &term =~ '256color'
    " disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
    set t_ut=
  endif

  " turn syntax highlighting on
  filetype indent plugin on
  syntax enable

  " setting the colorscheme, favorites listed here
  "set background=dark

  " prevent the colorscheme from overriding the default background color
  "hi Normal guibg=NONE ctermbg=NONE
  " force default text color
  "hi Normal ctermfg=white
  " other overrides
  "hi MatchParen ctermbg=none ctermfg=yellow

  let g:clear_background = 0
  " Adds or removes the background color. Can be used to help slow terminals.
  function! ToggleBackground()
    if g:clear_background == 0
      hi Normal guibg=NONE ctermbg=NONE
      let g:clear_background = 1
    else
      execute 'colorscheme ' . g:colors_name
      let g:clear_background = 0
    endif
  endfunction
  command ToggleBackground :call ToggleBackground()<Enter>

  " some draw speed tweaks
  set lazyredraw
  set synmaxcol=300  " default: 3000

  ]]

end

return M
