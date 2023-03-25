-- Config declarations that require NO PLUGINS
local M = {}

function M.packages(use)
  use 'https://github.com/tpope/vim-abolish.git'
  use 'https://github.com/MarcWeber/vim-addon-local-vimrc.git'
  use 'https://github.com/michaeljsmith/vim-indent-object.git'
  use{'https://github.com/tpope/vim-surround.git', dependencies = {'https://github.com/tpope/vim-repeat.git'}}
  use 'https://github.com/wellle/targets.vim'
  use 'danro/rename.vim'
  use 'https://github.com/tmhedberg/matchit.git'
  use 'https://github.com/Valloric/MatchTagAlways.git'
  use 'https://github.com/kana/vim-textobj-user.git'
  use {
  'glts/vim-textobj-comment',
  dependencies = {'https://github.com/kana/vim-textobj-user.git'},
}
  use{'https://github.com/AndrewRadev/splitjoin.vim.git', branch = 'main'}
  use{
  'https://github.com/Yggdroot/indentLine.git';
  config = function()
    vim.g.indentLine_char = "¦"
    vim.g.indentLine_fileType = {'yaml', 'lua', 'helm'}
  end;
};
  use{
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
  use{
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
  use{
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
  use{
  'mattn/emmet-vim',
  ft = {'html', 'liquid', 'eruby', 'typescript', 'javascript', 'reason', 'jinja.html'},
  config = function()
    vim.g.user_emmet_install_global = 1
    vim.g.user_emmet_leader_key = '<C-e>'
    require('rbar/mappings').emmet()
  end,
}
  use 'https://github.com/scrooloose/nerdcommenter.git'
  use 'https://github.com/tpope/vim-fugitive.git'
  use 'https://github.com/romainl/vim-qf.git'
  use 'https://github.com/yssl/QFEnter.git'

end

local function toggle_list_chars()
  vim.o.list = not vim.o.list
  print(vim.o.listchars)
end

function M.config()
  -- default indent options
  vim.o.filetype = 'on'
  vim.o.shiftwidth = 2
  vim.o.softtabstop = 2
  vim.o.tabstop = 2
  vim.o.expandtab = true

  vim.o.listchars = 'space:.,nbsp:+,tab:⇥ ,extends:>,precedes:<,trail:~,'
  vim.keymap.set('n', '<F8>', toggle_list_chars, { noremap = true })
  vim.keymap.set('v', '<F8>', toggle_list_chars, { noremap = true })
  vim.keymap.set('i', '<F8>', toggle_list_chars, { noremap = true })

  -- elimitnate escape sequence lag in vim (delay after leaving insert mode)
  vim.o.timeout = false
  vim.o.ttimeout = true
  vim.o.timeoutlen = 300
  vim.o.ttimeoutlen = 10

  -- sets shorter timeout for CursorHold event
  vim.o.updatetime = 100

  -- make the backspace work like we're used to
  vim.o.backspace = 'indent,eol,start'

  -- set the vim registry size
  vim.o.viminfo = "'100,h"

  -- set the terminal title
  vim.o.titlestring = '%t - VIM'
  -- vim.o.title = true

  -- enable mouse
  vim.o.mouse = 'a'

  -- Set a high value to have all folds opened by default
  -- https://vim.fandom.com/wiki/All_folds_open_when_opening_a_file
  vim.o.foldlevelstart = 20

  -- text wrapping options
  vim.o.textwidth = 80
  vim.o.formatoptions = 'jcroql'

  -- http://vim.wikia.com/wiki/Toggle_auto-wrap
  vim.cmd([[
  function! AutoWrapToggle()
    if &formatoptions =~ 't'
      set fo-=t
      echo "Auto wrap disabled"
    else
      set fo+=t
      echo "Auto wrap enabled"
    endif
  endfunction
  "imap <C-B> :call AutoWrapToggle()<CR>
  command -nargs=0 ToggleAutoWrap :call AutoWrapToggle()
]])

  vim.cmd([[command -nargs=0 Config :e $HOME/.config/nvim/init.vim]])

  -- allow current buffer to be put into the background without writing to disk
  vim.o.hidden = true

  -- search settings
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.hlsearch = true
  vim.o.incsearch = true

  -- set grep program
  if vim.fn.executable("rg") then
    vim.o.grepprg = [[rg --vimgrep --no-heading --with-filename --smart-case]]
    vim.o.grepformat = [[%f:%l:%c:%m,%f:%l:%m]]
  end
  vim.cmd([[autocmd QuickFixCmdPost * nested cwindow 20 | redraw!]])
  vim.keymap.set("n", "<leader>g", ':grep! "<cword>"<CR>')

  -- keep a couple lines between the cursor and the edge of the screen while
  -- scrolling
  vim.o.scrolloff = 3

  -- resize splits automatically when vim is resized
  vim.cmd([[autocmd VimResized * wincmd =]])


  -- Set F7 to toggle the spellchecker
  vim.cmd([[nn <F7> :setlocal spell! spell?<CR>]])

  -- shortcut to jump to last buffer
  vim.keymap.set('n', '<Backspace>', ':b#<Enter>', { noremap = true })

  -- map insert blank line below and above to enter and shift-enter
  vim.keymap.set('n', '<Enter>', 'i<Enter><ESC>', { noremap = true })
  --vim.api.nvim_set_keymap('n', '<Shift-Enter>', 'O<ESC>', {noremap = true})

  -- allow easier copy and pasting into the X clipboard
  vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })
  vim.keymap.set('n', '<leader>y', ':w ! xclip -selection clipboard<CR>', { noremap = true })

  -- Q mode sucks, never enter Q mode
  vim.keymap.set('n', 'Q', "<nop>")

  -- reload the file if no keys have been pressed in <updatetime> or when
  -- entering the buffer
  vim.cmd([[au BufEnter * :silent! !]])

  -- setup the gutter display
  vim.o.signcolumn = 'yes'
  vim.o.relativenumber = true
  vim.o.number = true

  -- command for writing files when accidentally opened without sudo
  vim.cmd([[command SudoW w ! sudo tee % > /dev/null]])

  -- pipe registers around more easily
  vim.cmd([[
  command! 
  \ -count=0 -nargs=? 
  \ -complete=file 
  \ DumpRegister 
  \ echo 'call writefile(getreg("<count>", 1, 1), empty(trim("<args>"))?tempname():trim("<args>"))'
]])

  vim.cmd([[
  command!
  \ -count=0 -nargs=+
  \ -complete=shellcmd
  \ PipeReg
  \ echo 'call system("<args>", getreg("r", 1, 1) + (getregtype("r") isnot# "v" ? [""] : []))'
]])
end

return M
