local M = {}
local set = vim.api.nvim_set_var

function M.git_changes(file)
  file = file or vim.api.nvim_buf_get_name(0)
  local handle = require('io').popen('git log --oneline '..file)
  local changes = {}
  for line in handle:lines('*a') do
    local id, message = line:match("([a-f%d]+) (.*)")
    if type(id) == 'string' and type(message) == 'string' then
      changes[id] = message
    end
  end
  handle:close()
  return changes
end

function M.previous_git_version(bufnr)
  bufnr = bufnr or 0
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local version = vim.fn.FugitiveStatusline(bufnr)
  local changes = M.git_changes(filename)
end

M.packages = {
  Package:new{
    "https://github.com/ThePrimeagen/harpoon.git",
    config = function()
      require('harpoon').setup({ save_on_toggle = true })
      vim.keymap.set('n', '<leader>m', function() require('harpoon.mark').add_file() end)
      vim.keymap.set('n', '<leader>o', function() require('harpoon.ui').nav_next() end)
      vim.keymap.set('n', '<leader>i', function() require('harpoon.ui').nav_prev() end)
      vim.keymap.set('n', '<leader>p', function() require('harpoon.cmd-ui').toggle_quick_menu() end)
      vim.keymap.set('n', '<ctrl-p>', function() require('harpoon.cmd-ui').toggle_quick_menu() end)
    end,
  },
  Package:new{
    'https://github.com/scrooloose/nerdcommenter.git',
    config = function()
      set('NERDAltDelims_haskell', 1)
      --[[
      set(
        'NERDCustomDelimiters',
        { purescript = { left = '--', leftAlt = '{--', rightAlt = '--}' }
        , reason = { left = '//', leftAlt = '/*', rightAlt = '*/' }
        , json = { left = '//' }
        }
      )
      --]]
    end
  };
  Package:new{'https://github.com/tpope/vim-fugitive.git'};
  Package:new{'https://github.com/tmhedberg/matchit.git'};
  Package:new{'https://github.com/Valloric/MatchTagAlways.git'};
  Package:new{'https://github.com/jiangmiao/auto-pairs.git'};
  Package:new{'https://github.com/kana/vim-textobj-user.git'};
  Package:new{'glts/vim-textobj-comment'};
  Package:new{'https://github.com/AndrewRadev/splitjoin.vim.git', branch = 'main'};
  Package:new{
    'https://github.com/L3MON4D3/LuaSnip.git',
    tag = 'v1.*',
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
      vim.cmd([[
        " press <Tab> to expand or jump in a snippet. These can also be mapped separately
        " via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
        ""imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
        " -1 for jumping backwards.
        ""inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

        snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
        snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>
      ]])
    end,
  };
  Package:new{'honza/vim-snippets'};
  Package:new{'https://github.com/rafamadriz/friendly-snippets.git'};
  Package:new{'junegunn/fzf', ['do'] = function() vim.fn['fzf#install']() end};
  Package:new{
    'junegunn/fzf.vim',
    config = function()
      vim.api.nvim_set_var('fzf_action', {
        ['ctrl-t'] = 'tab split';
        ['ctrl-x'] = 'split';
        ['ctrl-v'] = 'vsplit';
      })
      vim.cmd [[nnoremap <silent> <Leader>t :Files<Enter>]]
      vim.cmd [[nnoremap <silent> <Leader>b :Buffers<Enter>]]
      vim.cmd [[nnoremap <silent> <Leader>h :History<Enter>]]
      vim.cmd [[nnoremap <silent> <leader>j :BTags<Enter>]]
      vim.cmd [[nnoremap <silent> <leader>s :DocumentSymbols<Enter>]]
      vim.cmd [[nnoremap <silent> <leader>a :CodeActions<Enter>]]
      vim.cmd [[vnoremap <silent> <leader>a :RangeCodeActions<Enter>]]
    end
  };
  Package:new{
    'https://github.com/Yggdroot/indentLine.git';
    config = function()
      vim.g.indentLine_char = "¦"
      vim.g.indentLine_fileType = {'yaml', 'lua', 'helm'}
    end;
  };
  Package:new{
    'https://github.com/ludovicchabant/vim-gutentags.git';
    enabled = false and vim.fn.executable('ctags');
  };
  Package:new{
    'https://github.com/majutsushi/tagbar.git';
    enabled = false and vim.fn.executable('ctags');
  };
  Package:new{
    'editorconfig/editorconfig-vim',
    config = function()
      vim.g.EditorConfig_exclude_patterns = {'fugitive://.*', 'scp://.*'}
    end,
  };
  Package:new{
    'https://github.com/NarutoXY/silicon.lua.git',
    config = function()
      local silicon = require('silicon')
      require('silicon').setup{
        theme = 'OneHalfDark',
        font = 'Fira Code',
      }
      vim.api.nvim_create_user_command(
        'Screenshot',
        function(info)
          if vim.fn.executable('silicon') then
            local args = {}
            if string.match(info.args, 'clip') then
              args.to_clip = true
            end
            if string.match(info.args, 'buf') then
              args.show_buf = true
            end
            silicon.visualise_api(args)
          else
            print('Executable silicon must be installed to take screenshots')
          end
        end,
        { range = '%' }
      )
    end,
  }
}

return M
