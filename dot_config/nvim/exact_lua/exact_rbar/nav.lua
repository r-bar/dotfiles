---@type ConfigPkg
M = {}

function M.packages(use)
  use {
    'ibhagwan/fzf-lua',
    enabled = true,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local fzf = require("fzf-lua")
      vim.keymap.set("n", "<Leader>t", fzf.files, { silent = true })
      vim.keymap.set("n", "<Leader>b", fzf.buffers, { silent = true })
      vim.keymap.set("n", "<leader>s", fzf.lsp_document_symbols, { silent = true })
      vim.keymap.set("n", "<Leader>fc", fzf.command_history, { silent = true })
      vim.keymap.set("n", "<leader>fj", fzf.btags, { silent = true })
      vim.keymap.set("n", "<leader>fk", fzf.keymaps, { silent = true })
      vim.keymap.set("n", "<leader>fh", fzf.help_tags, { silent = true })
      vim.keymap.set({ "n", "v" }, "<leader>a", fzf.lsp_code_actions, { silent = true })
      vim.api.nvim_create_user_command("Help", fzf.help_tags, {})
    end
  }
  use {
    'ggandor/leap.nvim',
    keys = {
      {'s',       '<Plug>(leap-forward)',     mode = 'n', desc = 'Leap forward',     noremap = true},
      {'S',       '<Plug>(leap-backward)',    mode = 'n', desc = 'Leap backward',    noremap = true},
      {'gs',      '<Plug>(leap-from-window)', mode = 'n', desc = 'Leap from window', noremap = true},
      {'<space>', '<Plug>(leap)',             mode = 'n', desc = 'Leap in buffer',   noremap = true},
      {'s',       '<Plug>(leap-forward)',     mode = 'x', desc = 'Leap forward',     noremap = true},
      {'S',       '<Plug>(leap-backward)',    mode = 'x', desc = 'Leap backward',    noremap = true},
      {'gs',      '<Plug>(leap-from-window)', mode = 'x', desc = 'Leap from window', noremap = true},
      {'<space>', '<Plug>(leap)',             mode = 'x', desc = 'Leap in buffer',   noremap = true},
      {'s',       '<Plug>(leap-forward)',     mode = 'o', desc = 'Leap forward',     noremap = true},
      {'S',       '<Plug>(leap-backward)',    mode = 'o', desc = 'Leap backward',    noremap = true},
      {'gs',      '<Plug>(leap-from-window)', mode = 'o', desc = 'Leap from window', noremap = true},
      {'<space>', '<Plug>(leap)',             mode = 'o', desc = 'Leap in buffer',   noremap = true},
    },
  }
  use 'nvim-lua/plenary.nvim'
  use {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
      save_on_toggle = true,

      -- saves the harpoon file upon every change. disabling is unrecommended.
      save_on_change = true,

      -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
      enter_on_sendcmd = false,

      -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
      tmux_autoclose_windows = false,

      -- filetypes that you want to prevent from adding to the harpoon list menu.
      excluded_filetypes = { "harpoon" },

      -- set marks specific to each git branch inside git repository
      mark_branch = false,
    },
    config = function()
      local mark = require("harpoon.mark")
      local ui   = require("harpoon.ui")

      vim.keymap.set("n", "<leader>m", mark.add_file)
      vim.keymap.set("n", "<leader>o", ui.nav_next)
      vim.keymap.set("n", "<leader>i", ui.nav_prev)
      vim.keymap.set("n", "<leader>p", ui.toggle_quick_menu, { noremap = true })
      vim.keymap.set("n", "<C-p>", ui.toggle_quick_menu, { noremap = true })

      vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { noremap = true })
      vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { noremap = true })
      vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { noremap = true })
      vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, { noremap = true })

      vim.keymap.set("n", "<A-1>", function() ui.nav_file(1) end, { noremap = true })
      vim.keymap.set("n", "<A-2>", function() ui.nav_file(2) end, { noremap = true })
      vim.keymap.set("n", "<A-3>", function() ui.nav_file(3) end, { noremap = true })
      vim.keymap.set("n", "<A-4>", function() ui.nav_file(4) end, { noremap = true })
    end,
  }
  use "christoomey/vim-tmux-navigator"
  use {
    "nvim-treesitter/nvim-treesitter-context",
    opts = true,
  }
  use "farmergreg/vim-lastplace"
  use {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      {"<C-e>", "<cmd>Oil<CR>", mode = "n", noremap = true, desc = "Open parent directory" },
    },
    opts = {
      columns = { "permissions", "mtime", "size", "icon" },
      constrain_cursor = "name",
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["!"] = "actions.open_terminal",
        ["<F5>"] = "actions.refresh",
      },
      view_options = { show_hidden = true },
    },
  }
  use {
    "numToStr/FTerm.nvim",
    cmd = { "FTermOpen", "FTermClose", "FTermToggle" },
    opts = {
      border = "double",
    },
    config = function()
      local fterm = require("FTerm")
      vim.api.nvim_create_user_command('FTermOpen', fterm.open, { bang = true })
      vim.api.nvim_create_user_command(
        'FTermOpenParent',
        function()
          local file_parent = vim.fs.dirname(vim.fn.expand("%"))
          require('FTerm').run({'cd', file_parent})
        end,
        { bang = true }
      )
      vim.api.nvim_create_user_command('FTermClose', fterm.close, { bang = true })
      vim.api.nvim_create_user_command('FTermToggle', fterm.toggle, { bang = true })
    end,
  }
  use {
    'Mathijs-Bakker/zoom-vim',
    keys = {
      {'<C-w>z', '<Plug>Zoom', mode = 'n', desc = 'Zoom window', noremap = true},
    },
  }
end

function M.config()
  vim.keymap.set('n', '+', '<C-w>+', { noremap = true })
  vim.keymap.set('n', '-', '<C-w>-', { noremap = true })
end

return M
