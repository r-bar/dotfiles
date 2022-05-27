local config = require('utils').Config:new()
local Package = require('utils').Package
local set = vim.api.nvim_set_var

config.packages = {

  Package:new{'https://github.com/scrooloose/nerdcommenter.git', config = function()
    set('NERDAltDelims_haskell', 1)
    ----[[
    set(
      'NERDCustomDelimiters',
      { purescript = { left = '--', leftAlt = '{--', rightAlt = '--}' }
      , reason = { left = '//', leftAlt = '/*', rightAlt = '*/' }
      , json = { left = '//' }
      }
    )
    --]]
  end};
  Package:new{'https://github.com/tpope/vim-fugitive.git'};
  Package:new{'https://github.com/tmhedberg/matchit.git'};
  Package:new{'https://github.com/Valloric/MatchTagAlways.git'};
  Package:new{'https://github.com/jiangmiao/auto-pairs.git'};
  Package:new{'https://github.com/kana/vim-textobj-user.git'};
  Package:new{'glts/vim-textobj-comment'};

  Package:new{'https://github.com/AndrewRadev/splitjoin.vim.git', branch = 'main'};
  Package:new{'SirVer/ultisnips', config = function()
    vim.g.UltiSnipsExpandTrigger = "<leader>u"
    vim.g.UltiSnipsSnippetDirectories = {
      'UltiSnips';
      os.getenv('HOME')..'/.vim/bundle/vim-snippets/UltiSnips';
    }
  end};
  Package:new{'honza/vim-snippets'};
  Package:new{'junegunn/fzf', ['do'] = function() vim.fn['fzf#install']() end};
  Package:new{'junegunn/fzf.vim', config = function()
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
  end};
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
}

return config
