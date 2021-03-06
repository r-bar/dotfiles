local M = {}
local echom = require('utils').echom
local run = require('utils').run
local set = vim.api.nvim_set_var

local function python_provider()
  if vim.fn.executable('podman') then
  elseif vim.fn.executable('docker') then
  else
    vim.cmd('')
    vim.fn.system('')
  end
end

M.packages = {
  Package:new{'https://github.com/nvim-lua/plenary.nvim.git'};
  Package:new{'https://github.com/vim-scripts/LargeFile.git'};
  Package:new{'https://github.com/vim-scripts/IndentAnything.git'};
  Package:new{'https://github.com/MarcWeber/vim-addon-local-vimrc.git'};
  Package:new{'https://github.com/michaeljsmith/vim-indent-object.git'};
  Package:new{'https://github.com/tpope/vim-repeat.git'};
--  Package:new{
--    'https://github.com/xolox/vim-session.git';
--    requires = 'https://github.com/xolox/vim-misc.git':
--    config = function()
--      set('session_autoload', 'no')
--      set('session_autosave', 'yes')
--      set('session_autosave_to', 'autosave')
--      set('session_autosave_silent', 'yes')
--    end;
--  };
  Package:new{'https://github.com/tpope/vim-surround.git'};
  -- more control about where a buffer is sent from quickfix
  Package:new{'https://github.com/yssl/QFEnter.git'};
  -- additional quickfix window keybindings and more
  Package:new{'https://github.com/romainl/vim-qf.git', config = function()
    -- vim-qf use ack.vim style quickfix mappings
    vim.g.qf_mapping_ack_style = 1
  end};
  Package:new{'https://github.com/wellle/targets.vim'};
  Package:new{'https://github.com/easymotion/vim-easymotion.git', config = function()
    --set('EasyMotion_smartcase', 1)
    --set('EasyMotion_do_mapping', 1)
  end};
  -- nix package manager syntax
  Package:new{'LnL7/vim-nix'};
  Package:new{'https://github.com/kana/vim-fakeclip.git'};
  Package:new{'danro/rename.vim'};
  Package:new{'tpope/vim-abolish'};
}

function M.config()

  -- default indent options
  vim.o.filetype = 'on'
  vim.o.shiftwidth = 2
  vim.o.softtabstop = 2
  vim.o.tabstop = 2
  vim.o.expandtab = true

  vim.o.listchars = 'space:.,nbsp:+,tab:??? ,extends:>,precedes:<,trail:~,'
  vim.api.nvim_set_keymap('n', '<F8>', ':set list! | echo &listchars<CR>', {noremap = true})
  vim.api.nvim_set_keymap('v', '<F8>', ':set list! | echo &listchars<CR>', {noremap = true})
  vim.api.nvim_set_keymap('i', '<F8>', ':set list! | echo &listchars<CR>', {noremap = true})

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

  -- keep a couple lines between the cursor and the edge of the screen while
  -- scrolling
  vim.o.scrolloff = 3

  -- set a directory so .swp and backup files are not spread around the system
  --if not vim.fn.isdirectory(vim.env.HOME .. '/.cache/nvim/swpbak') then
    --vim.cmd([[:silent !mkdir -p ~/.cache/nvim/swpbak > /dev/null 2>&1]])
  --end
  --vim.o.backupdir = [[~/.cache/nvim/swpbak//,/tmp//]]
  --vim.o.directory = [[~/.cache/nvim/swpbak//,/tmp//]]

  vim.o.fillchars = 'vert:|'

  -- Jump to the last open position when reopening a file
  if vim.fn.has('autocmd') then
    vim.cmd([[au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])
  end

  -- highlight trailing whitespace
  -- http://vim.wikia.com/wiki/Highlight_unwanted_spaces
  --vim.cmd([[highlight ExtraWhitespace ctermbg=red guibg=red]])
  --vim.cmd([[autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/ containedin=ALL]])

  -- resize splits automatically when vim is resized
  vim.cmd([[autocmd VimResized * wincmd =]])


  -- Set F7 to toggle the spellchecker
  vim.cmd([[nn <F7> :setlocal spell! spell?<CR>]])

  -- Shortcuts for navigating between windows
  vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', {noremap = true})
  vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', {noremap = true})
  vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', {noremap = true})
  vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', {noremap = true})

  vim.api.nvim_set_keymap('n', '+', '<C-w>+', {noremap = true})
  vim.api.nvim_set_keymap('n', '-', '<C-w>-', {noremap = true})


  -- shortcut to jump to last buffer
  vim.api.nvim_set_keymap('n', '<Backspace>', ':b#<Enter>', {noremap = true})

  -- map insert blank line below and above to enter and shift-enter
  vim.api.nvim_set_keymap('n', '<Enter>', 'i<Enter><ESC>', {noremap = true})
  --vim.api.nvim_set_keymap('n', '<Shift-Enter>', 'O<ESC>', {noremap = true})

  -- allow easier copy and pasting into the X clipboard
  vim.api.nvim_set_keymap('v', '<C-c>', '"+y', {noremap = true})
  vim.api.nvim_set_keymap('n', '<leader>y', ':w ! xclip -selection clipboard<CR>', {noremap = true})


  -- reload the file if no keys have been pressed in <updatetime> or when
  -- entering the buffer
  vim.cmd([[au BufEnter * :silent! !]])


  -- setup the gutter display
  vim.o.signcolumn = 'yes'
  vim.o.relativenumber = true
  vim.o.number = true

  vim.api.nvim_set_keymap('n', '<leader>n', ':set number!<CR>', {noremap = true})

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

  vim.g.python3_host_prog = vim.env.NVIM_PYTHON or '/usr/bin/python3'

end

return M
