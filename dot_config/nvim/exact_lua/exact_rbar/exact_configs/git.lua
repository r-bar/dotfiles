-- Integration with git

---@type ConfigPkg
local M = {}

function M.on_attach(bufnr)
end

function M.packages(use)
  use {
    'https://github.com/tpope/vim-fugitive.git',
    cmd = {
      'G', 'GBrowse', 'GDelete', 'GMove', 'GRemove', 'GRename', 'GUnlink',
      'Gbrowse', 'GcLog', 'Gcd', 'Gclog', 'Gdelete', 'Gdiffsplit', 'Gdrop',
      'Ge', 'Gedit', 'Ggrep', 'Ghdiffsplit', 'Git', 'Gitsigns', 'GlLog', 'Glcd',
      'Glgrep', 'Gllog', 'Gmove', 'Gpedit', 'Gr', 'Gread', 'Gremove', 'Grename',
      'Gsplit', 'Gtabedit', 'Gvdiffsplit', 'Gvsplit', 'Gw', 'Gwq', 'Gwrite',
    },
    depedencies = { 'tpope/vim-rhubarb' },
  }

  use {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach                    = M.on_attach,
      -- Configuration options
      signs                        = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signcolumn                   = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir                 = {
        follow_files = true
      },
      auto_attach                  = true,
      attach_to_untracked          = false,
      current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'eol',   -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      sign_priority                = 6,
      update_debounce              = 100,
      status_formatter             = nil, -- Use default
      max_file_length              = 40000, -- Disable if file is longer than this (in lines)
      preview_config               = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
    },
    config = function()
      local gitsigns = require('gitsigns')

      --local function map(mode, l, r, opts)
      --  opts = opts or {}
      --  opts.buffer = bufnr
      --  vim.keymap.set(mode, l, r, opts)
      --end

      local map = vim.keymap.set

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gitsigns.nav_hunk('next')
        end
      end)

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gitsigns.nav_hunk('prev')
        end
      end)

      -- Actions
      map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "GitSigns: stage hunk" })
      map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "GitSigns: reset hunk" })
      map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { desc = "GitSigns: stage hunk" })
      map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { desc = "GitSigns: reset hunk" })
      map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "GitSigns: stage buffer" })
      map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "GitSigns: reset buffer" })
      map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "GitSigns: preview hunk" })
      map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = "GitSigns: show line blame" })
      map('n', '<leader>hb', gitsigns.toggle_current_line_blame, { desc = "GisSigns: toggle line blame" })
      map('n', '<leader>hd', gitsigns.diffthis, { desc = "GitSigns: perform a vimdiff on this file against the index" })
      map('n', '<leader>hD', function() gitsigns.diffthis('~') end,
        { desc = "GitSigns: perform a vimdiff on this file against the last commit" })

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  }
end

return M
