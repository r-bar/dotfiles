local M = {}

local function bufchanged()
  local bufnr = vim.fn.bufnr()
  local bufinfo = vim.fn.getbufinfo(bufnr)[1]
  if bufinfo.changed == 1 then
    return '(changed)'
  else
    return ''
  end
end

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
      -- Use fugitive to get a nice buffer name. Implementation borrowed from
      -- airline:
      -- https://github.com/vim-airline/vim-airline/blob/0241bdb804990a965b8a8988a8b37ce16e6e0486/autoload/airline/extensions/fugitiveline.vim#L13
      vim.cmd[[
        function! FugitiveBufname()
          if !exists('b:fugitive_name')
            let b:fugitive_name = ''
            try
              if bufname('%') =~? '^fugitive:' && exists('*FugitiveReal')
                let b:fugitive_name = FugitiveReal(bufname('%'))
              elseif exists('b:git_dir') && exists('*fugitive#repo')
                if get(b:, 'fugitive_type', '') is# 'blob'
                  let b:fugitive_name = fugitive#repo().translate(FugitivePath(@%, ''))
                endif
              elseif exists('b:git_dir') && !exists('*fugitive#repo')
                let buffer = fugitive#buffer()
                if buffer.type('blob')
                  let b:fugitive_name = buffer.repo().translate(buffer.path('/'))
                endif
              endif
            catch
            endtry
          endif

          let fmod = (exists("+autochdir") && &autochdir) ? ':p' : ':.'
          let result=''
          if empty(b:fugitive_name)
            if empty(bufname('%'))
              return &buftype ==# 'nofile' ? '[Scratch]' : '[No Name]'
            endif
            return fnamemodify(bufname('%'), fmod)
          else
            return (fnamemodify(b:fugitive_name, fmod). " [git]")
          endif
        endfunction
      ]]

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
          lualine_c = {'FugitiveBufname', bufchanged},
          lualine_x = {'diagnostics'},
          lualine_y = {'encoding', 'fileformat', 'filetype'},
          lualine_z = {'progress', 'location'},
        },
        extensions = {'quickfix', 'fzf', 'fugitive'},
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'FugitiveBufname', bufchanged},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
      }
    end,
  },
}

function M.config()
  vim.o.cmdheight = 2
end

return M
