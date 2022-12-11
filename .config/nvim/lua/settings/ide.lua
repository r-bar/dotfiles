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
  -- allows better jumping with %
  Package:new{'https://github.com/tmhedberg/matchit.git'};
  Package:new{'https://github.com/Valloric/MatchTagAlways.git'};
  Package:new{'https://github.com/kana/vim-textobj-user.git'};
  Package:new{'glts/vim-textobj-comment'};
  Package:new{'https://github.com/AndrewRadev/splitjoin.vim.git', branch = 'main'};
  Package:new{
    'junegunn/fzf.vim',
    ['do'] = function() vim.fn['fzf#install']() end,
    config = function()
      vim.g.fzf_action = {
        ['ctrl-t'] = 'tab split';
        ['ctrl-x'] = 'split';
        ['ctrl-v'] = 'vsplit';
      }
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
  -- loads .editorconfig files
  -- https://editorconfig.org/
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
        { range = '%', nargs = '*' }
      )
    end,
  },
  Package:new{
    'https://github.com/windwp/nvim-autopairs.git',
    config = function()
      require("nvim-autopairs").setup{
        check_ts = true,
        ts_config = {
          lua = {'string'},-- it will not add a pair on that treesitter node
          javascript = {'template_string'},
          java = false,-- don't check treesitter on java
        }
      }
    end,
  },
  Package:new{
    'https://github.com/jiangmiao/auto-pairs.git',
    enabled = false,
    config = function()
      vim.api.nvim_create_autocmd({"FileType"}, {
        pattern = {"*.py"},
        callback = function()
          -- local python_pairs = {}
          vim.b.AutoPairs = vim.tbl_extend("force", vim.g.AutoPairs, {
            ["f'"] = "'",
            ['f"'] = '"',
            ["r'"] = "'",
            ['r"'] = '"',
            ["b'"] = "'",
            ['b"'] = '"',
          })
        end,
      })
      --vim.api.nvim_create_autocmd({"FileType"}, {
      --  pattern = {"*.html", "*.md", "*.html.j2"},
      --  callback = function()
      --    -- local python_pairs = {}
      --    vim.b.AutoPairs = vim.tbl_extend("force", vim.g.AutoPairs, {
      --      ["<div>"] = "</div>",
      --    })
      --  end,
      --})
    end,
  },
}

return M
