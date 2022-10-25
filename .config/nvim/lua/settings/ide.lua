local M = {}
local set = vim.api.nvim_set_var

M.packages = {

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
  --Package:new{'SirVer/ultisnips', config = function()
  --  vim.g.UltiSnipsExpandTrigger = "<leader>u"
  --  vim.g.UltiSnipsSnippetDirectories = {
  --    'UltiSnips';
  --    os.getenv('HOME')..'/.vim/bundle/vim-snippets/UltiSnips';
  --  }
  --end};
  Package:new{'honza/vim-snippets'};
  Package:new{'https://github.com/rafamadriz/friendly-snippets.git'};
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
  Package:new{'editorconfig/editorconfig-vim',
    config = function()
      vim.g.EditorConfig_exclude_patterns = {'fugitive://.*', 'scp://.*'}
    end
  };
}

return M
