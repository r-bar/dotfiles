local M = {}

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
    'https://github.com/scrooloose/nerdcommenter.git',
    config = function()
      vim.g['NERDAltDelims_haskell'] = 1
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
    "https://github.com/mbbill/undotree.git",
    config = function()
      vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>')
      vim.cmd [[
      if has("persistent_undo")
        let target_path = expand('~/.undodir')

        " create the directory and any parent directories
        " if the location does not exist.
        if !isdirectory(target_path)
          call mkdir(target_path, "p", 0700)
        endif

        let &undodir=target_path
        set undofile
      endif
      ]]
    end,
  },
}

return M
