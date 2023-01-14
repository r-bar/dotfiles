local loader = require('loader')

loader.lazy_use 'https://github.com/MarcWeber/vim-addon-local-vimrc.git'
loader.lazy_use 'https://github.com/michaeljsmith/vim-indent-object.git'
loader.lazy_use{'https://github.com/tpope/vim-surround.git', requires = 'https://github.com/tpope/vim-repeat.git'}
loader.lazy_use 'https://github.com/wellle/targets.vim'
loader.lazy_use 'danro/rename.vim'
loader.lazy_use 'https://github.com/tmhedberg/matchit.git'
loader.lazy_use 'https://github.com/Valloric/MatchTagAlways.git'
loader.lazy_use 'https://github.com/kana/vim-textobj-user.git'
loader.lazy_use 'glts/vim-textobj-comment'
loader.lazy_use{'https://github.com/AndrewRadev/splitjoin.vim.git', branch = 'main'}
loader.lazy_use{
  'https://github.com/Yggdroot/indentLine.git';
  config = function()
    vim.g.indentLine_char = "¦"
    vim.g.indentLine_fileType = {'yaml', 'lua', 'helm'}
  end;
};
loader.lazy_use{
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
}
loader.lazy_use{
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
}
loader.lazy_use{
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
}
loader.lazy_use{
  'mattn/emmet-vim',
  ft = {'html', 'liquid', 'eruby', 'typescript', 'javascript', 'reason', 'jinja.html'},
  config = function()
    vim.cmd[[
      " remap emmet trigger key to not interfere with ycm / deoplete
      let g:user_emmet_install_global = 1
      let g:user_emmet_leader_key='<C-e>'
      "imap   <C-e><C-e>   <C-o>:<plug>(emmet-expand-abbr)<CR>
      "imap   <C-e>;   <C-o>:<plug>(emmet-expand-word)<CR>
      "imap   <C-e>u   <C-o>:<plug>(emmet-update-tag)<CR>
      "imap   <C-e>d   <C-o>:<plug>(emmet-balance-tag-inward)<CR>
      "imap   <C-e>D   <C-o>:<plug>(emmet-balance-tag-outward)<CR>
      "imap   <C-e>n   <C-o>:<plug>(emmet-move-next)<CR>
      "imap   <C-e>N   <C-o>:<plug>(emmet-move-prev)<CR>
      "imap   <C-e>i   <C-o>:<plug>(emmet-image-size)<CR>
      "imap   <C-e>/   <C-o>:<plug>(emmet-toggle-comment)<CR>
      "imap   <C-e>j   <C-o>:<plug>(emmet-split-join-tag)<CR>
      "imap   <C-e>k   <C-o>:<plug>(emmet-remove-tag)<CR>
      "imap   <C-e>a   <C-o>:<plug>(emmet-anchorize-url)<CR>
      "imap   <C-e>A   <C-o>:<plug>(emmet-anchorize-summary)<CR>
      "imap   <C-e>m   <C-o>:<plug>(emmet-merge-lines)<CR>
      "imap   <C-e>c   <C-o>:<plug>(emmet-code-pretty)<CR>
      ]]
  end,
}
loader.lazy_use 'https://github.com/scrooloose/nerdcommenter.git'


loader.load 'rbar/base'
loader.load 'rbar/colors'
loader.load 'rbar/lualine'
loader.load 'rbar/treesitter'
loader.load 'rbar/lsp'
loader.load 'rbar/harpoon'
loader.load 'rbar/fzf'
loader.load 'rbar/syntax'
loader.load 'rbar/ft_python'

vim.g.python3_host_prog = vim.env.NVIM_PYTHON or '/usr/bin/python3'

loader.init()
