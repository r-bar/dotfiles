-- Config declarations that require NO PLUGINS
---@type ConfigPkg
local M = {}

function M.packages(use)
  use {
    'https://github.com/tpope/vim-abolish.git',
    cmd = {
      'Abolish',
      'Subvert',
      'S',
    }
  }
  use {
    "klen/nvim-config-local",
    opts = {
      -- Default options (optional)

      -- Config file patterns to load (lua supported)
      config_files = { ".nvim.lua" },

      -- Where the plugin keeps files data
      hashfile = vim.fn.stdpath("data") .. "/config-local",

      autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
      commands_create = true,     -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalIgnore)
      silent = false,             -- Disable plugin messages (Config loaded/ignored)
      lookup_parents = true,      -- Lookup config files in parent directories
    },
  }
  use 'https://github.com/michaeljsmith/vim-indent-object.git'
  use 'https://github.com/tpope/vim-repeat.git'
  use {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    opts = {
      keymaps = {
        insert          = '<C-g>z',
        insert_line     = '<C-g>Z',
        normal          = 'gz',
        normal_cur      = 'gZ',
        normal_line     = 'gzgz',
        normal_cur_line = 'gZgZ',
        visual          = 'gz',
        visual_line     = 'gZ',
        delete          = 'dgz',
        change          = 'cgz',
      }
    },
  }
  use 'https://github.com/wellle/targets.vim'
  use { 'danro/rename.vim', cmd = "Rename" }
  use { 'https://github.com/Valloric/MatchTagAlways.git', enabled = false }
  use { 'https://github.com/andymass/vim-matchup' }
  use 'https://github.com/kana/vim-textobj-user.git'
  use {
    'glts/vim-textobj-comment',
    dependencies = { 'https://github.com/kana/vim-textobj-user.git' },
  }
  use {
    'https://github.com/bennypowers/splitjoin.nvim',
    branch = 'main',
    config = function()
      local splitjoin = require('splitjoin')
      vim.keymap.set('n', 'gj', splitjoin.split, { noremap = true, desc = 'Split the object under the cursor' })
      vim.keymap.set('n', 'gJ', splitjoin.join, { noremap = true, desc = 'Split the object under the cursor' })
    end,
  }
  use {
    'echasnovski/mini.indentscope',
    version = '*',
    config = function()
      local scope = require('mini.indentscope')
      scope.setup({
        draw = {
          delay = 200,
          animation = scope.gen_animation.quadratic({
            duration = 200,
            easing = 'in',
            unit = 'total',
          }),
        },
      })
    end,
  }
  use {
    'https://github.com/NarutoXY/silicon.lua.git',
    opts = {
      theme = 'OneHalfDark',
      font = 'Fira Code',
    },
    cmd = 'Screenshot',
    config = function()
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
            require('silicon').visualise_api(args)
          else
            print('Executable `silicon` must be installed to take screenshots')
          end
        end,
        { range = '%', nargs = '*' }
      )
    end,
  }
  use {
    'https://github.com/windwp/nvim-autopairs.git',
    enabled = true,
    --opts = {
    --  check_ts = true,
    --  ts_config = {
    --    lua = { 'string' }, -- it will not add a pair on that treesitter node
    --    javascript = { 'template_string' },
    --    java = false,       -- don't check treesitter on java
    --  },
    --},
    config = function()
      local npairs = require('nvim-autopairs')
      local Rule = require('nvim-autopairs.rule')
      local cond = require('nvim-autopairs.conds')
      npairs.setup {
        check_ts = true,
        ts_config = {
          lua = { 'string' }, -- it will not add a pair on that treesitter node
          javascript = { 'template_string' },
          java = false,       -- don't check treesitter on java
        },
      }
      npairs.add_rules({
        Rule("`", "`")
            :with_pair(cond.not_filetypes({ "ocaml", "rust" })),
        Rule("'", "'")
            :with_pair(cond.not_filetypes({ "ocaml", "rust" })),
        Rule("(*", "*", "ocaml")
            :with_move(cond.none()),
      })
    end,
  }
  use {
    "https://github.com/mbbill/undotree.git",
    cmd = {
      "UndotreeToggle",
      "UndotreeShow",
      "UndotreeHide",
      "UndotreeFocus",
      "UndotreePersistUndo",
    },
    keys = {
      { '<leader>u', ':UndotreeToggle<CR>' },
    },
    config = function()
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
  use {
    'mattn/emmet-vim',
    --enabled = false,
    ft = { 'html', 'liquid', 'eruby', 'typescript', 'javascript', 'reason', 'jinja.html' },
    init = function()
      vim.g.user_emmet_leader_key = '<C-e>'
      vim.g.user_emmet_install_global = 1
      vim.g.emmet_html5 = 1
    end,
  }
  use {
    'https://github.com/scrooloose/nerdcommenter.git',
    keys = {
      { '<leader>cc',       '<Plug>NERDCommenterComment',   mode = { 'n', 'v' }, noremap = true },
      { '<leader>cc',       '<Plug>NERDCommenterComment',   mode = { 'n', 'v' }, noremap = true },
      { '<leader>c',        '<Plug>NERDCommenterToEOL',     mode = { 'n', 'v' }, noremap = true },
      { '<leader>c<space>', '<Plug>NERDCommenterToggle',    mode = { 'n', 'v' }, noremap = true },
      { '<leader>cA',       '<Plug>NERDCommenterAppend',    mode = { 'n', 'v' }, noremap = true },
      { '<leader>ca',       '<Plug>NERDCommenterAltDelims', mode = { 'n', 'v' }, noremap = true },
      { '<leader>cb',       '<Plug>NERDCommenterAlignBoth', mode = { 'n', 'v' }, noremap = true },
      { '<leader>ci',       '<Plug>NERDCommenterInvert',    mode = { 'n', 'v' }, noremap = true },
      { '<leader>cl',       '<Plug>NERDCommenterAlignLeft', mode = { 'n', 'v' }, noremap = true },
      { '<leader>cm',       '<Plug>NERDCommenterMinimal',   mode = { 'n', 'v' }, noremap = true },
      { '<leader>cn',       '<Plug>NERDCommenterNested',    mode = { 'n', 'v' }, noremap = true },
      { '<leader>cs',       '<Plug>NERDCommenterSexy',      mode = { 'n', 'v' }, noremap = true },
      { '<leader>cu',       '<Plug>NERDCommenterUncomment', mode = { 'n', 'v' }, noremap = true },
      { '<leader>cy',       '<Plug>NERDCommenterYank',      mode = { 'n', 'v' }, noremap = true },
      { '<leader>c<space>', '<Plug>NERDCommenterToggle',    mode = { 'n', 'v' }, noremap = true },
      { '<leader>cb',       '<Plug>NERDCommenterAlignBoth', mode = { 'n', 'v' }, noremap = true },
      { '<leader>ci',       '<Plug>NERDCommenterInvert',    mode = { 'n', 'v' }, noremap = true },
      { '<leader>cl',       '<Plug>NERDCommenterAlignLeft', mode = { 'n', 'v' }, noremap = true },
      { '<leader>cm',       '<Plug>NERDCommenterMinimal',   mode = { 'n', 'v' }, noremap = true },
      { '<leader>cn',       '<Plug>NERDCommenterNested',    mode = { 'n', 'v' }, noremap = true },
      { '<leader>cs',       '<Plug>NERDCommenterSexy',      mode = { 'n', 'v' }, noremap = true },
      { '<leader>cu',       '<Plug>NERDCommenterUncomment', mode = { 'n', 'v' }, noremap = true },
      { '<leader>cy',       '<Plug>NERDCommenterYank',      mode = { 'n', 'v' }, noremap = true },
    },
    config = function()
      vim.g.NERDCustomDelimiters = {
        kdl = { left = '//', leftAlt = '/*', rightAlt = '*/' },
        mojo = { left = '# ' },
        gleam = { left = '// ', leftAlt = '/// ' },
      }
    end
  }
  use {
    'https://github.com/tpope/vim-fugitive.git',
    cmd = {
      'G', 'GBrowse', 'GDelete', 'GMove', 'GRemove', 'GRename', 'GUnlink',
      'Gbrowse', 'GcLog', 'Gcd', 'Gclog', 'Gdelete', 'Gdiffsplit', 'Gdrop',
      'Ge', 'Gedit', 'Ggrep', 'Ghdiffsplit', 'Git', 'Gitsigns', 'GlLog', 'Glcd',
      'Glgrep', 'Gllog', 'Gmove', 'Gpedit', 'Gr', 'Gread', 'Gremove', 'Grename',
      'Gsplit', 'Gtabedit', 'Gvdiffsplit', 'Gvsplit', 'Gw', 'Gwq', 'Gwrite',
    },
  }
  use 'https://github.com/romainl/vim-qf.git'
  use 'https://github.com/yssl/QFEnter.git'
  use {
    'https://github.com/junegunn/vim-easy-align.git',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = 'n', noremap = false, desc = "Align text by delimiters" },
      { 'ga', '<Plug>(EasyAlign)', mode = 'x', noremap = false, desc = "Align text by delimiters" },
    },
  }
  use {
    "andrewferrier/debugprint.nvim",
    opts = true,
  }
  use {
    "xvzc/chezmoi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    config = function()
      -- apply changes on save for all files in ~/.local/share/chezmoi/
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
        callback = function(ev)
          local bufnr = ev.buf
          local edit_watch = function()
            require("chezmoi.commands.__edit").watch(bufnr)
          end
          vim.schedule(edit_watch)
          print("Chezmoi file detected. Changes will be applied on save.")
        end,
      })
    end,
  }
end

function M.config()
  -- default indent options
  vim.o.filetype = 'on'
  vim.o.shiftwidth = 2
  vim.o.softtabstop = 2
  vim.o.tabstop = 2
  vim.o.expandtab = true

  vim.o.listchars = 'space:.,nbsp:+,tab:⇥ ,extends:>,precedes:<,trail:~,'
  --vim.keymap.set('n', '<F8>', toggle_list_chars, { noremap = true })
  --vim.keymap.set('v', '<F8>', toggle_list_chars, { noremap = true })
  --vim.keymap.set('i', '<F8>', toggle_list_chars, { noremap = true })

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
  vim.keymap.set("n", "<leader>g", ':grep! "<cword>"<CR>',
    { noremap = true, desc = 'Grep for the word under the cursor' })

  -- keep a couple lines between the cursor and the edge of the screen while
  -- scrolling
  vim.o.scrolloff = 3

  -- map local leader key used for filetype specific mappings
  vim.g.maplocalleader = ','

  -- resize splits automatically when vim is resized
  vim.cmd([[autocmd VimResized * wincmd =]])


  -- Set F7 to toggle the spellchecker
  vim.cmd([[nn <F7> :setlocal spell! spell?<CR>]])

  -- shortcut to jump to last buffer
  vim.keymap.set('n', '<Backspace>', ':b#<Enter>', { noremap = true, desc = 'Jump to the previous active buffer' })

  -- map insert blank line below and above to enter and shift-enter
  vim.keymap.set('n', '<Enter>', 'i<Enter><ESC>',
    { noremap = true, desc = 'Insert a newline at the cursor, return to normal mode' })
  --vim.api.nvim_set_keymap('n', '<Shift-Enter>', 'O<ESC>', {noremap = true})

  -- allow easier copy and pasting into the X clipboard
  vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, desc = 'Yank for Windows users' })
  vim.keymap.set('n', '<leader>y', ':w ! clip -r localhost',
    { noremap = true, desc = 'Yank full buffer to system clipboard' })

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

  local function generate_uuid()
    math.randomseed(os.time())
    local random = math.random
    local template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    return string.gsub(template, "x", function()
      local v = random(0, 0xf)      -- v is a decimal number 0 to 15
      return string.format("%x", v) --formatted as a hex number
    end)
  end

  --[[ Generate a uuid and place it at current cursor position --]]
  local function insert_uuid()
    -- Get row and column cursor,
    -- use unpack because it's a tuple.
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local uuid = generate_uuid()
    -- Notice the uuid is given as an array parameter, you can pass multiple strings.
    -- Params 2-5 are for start and end of row and columns.
    -- See earlier docs for param clarification or `:help nvim_buf_set_text.
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
    vim.api.nvim_win_set_cursor(0, { row, col + uuid:len() })
  end

  -- Finally we map this somewhere to the key and mode we want.
  -- i stands for insert mode next set the insert_uuid without invoking it.
  -- For the last parameter see `:help map-arguments`  and adjust accordingly.
  vim.keymap.set('i', '<C-g>u', insert_uuid, { noremap = true, silent = true })
  -- conflicts with lowercase command
  --vim.keymap.set('n', 'gu', insert_uuid, { noremap = true, silent = true })

  vim.keymap.set(
    { "n", "v" }, "]q", "<cmd>cne<cr>",
    { silent = true, desc = "Jump to the next entry in the quickfix list" }
  )
  vim.keymap.set(
    { "n", "v" }, "[q", "<cmd>cpr<cr>",
    { silent = true, desc = "Jump to the previous entry in the quickfix list" }
  )

  vim.keymap.set(
    { "n", "v" }, "]l", "<cmd>lne<cr>",
    { silent = true, desc = "Jump to the next entry in the location list" }
  )
  vim.keymap.set(
    { "n", "v" }, "[l", "<cmd>lpr<cr>",
    { silent = true, desc = "Jump to the previous entry in the location list" }
  )

  -- Heading comment insertion
  vim.keymap.set('n', '<leader>=', 'yypVr#', { desc = "Make title comment", noremap = true })
end

return M
