M = {}


function M.packages(use)
  use {
    'ibhagwan/fzf-lua',
    enabled = true,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local fzf = require("fzf-lua")
      vim.keymap.set("n", "<Leader>t", ":FzfLua files<Enter>", { silent = true })
      vim.keymap.set("n", "<Leader>b", ":FzfLua buffers<Enter>", { silent = true })
      vim.keymap.set("n", "<Leader>h", ":FzfLua command_history<Enter>", { silent = true })
      vim.keymap.set("n", "<leader>j", ":FzfLua btags<Enter>", { silent = true })
      vim.keymap.set("n", "<leader>s", ":FzfLua lsp_document_symbols<Enter>", { silent = true })
      vim.keymap.set({ "n", "v" }, "<leader>a", ":FzfLua lsp_code_actions<Enter>", { silent = true })
      vim.api.nvim_create_user_command("Help", function() fzf.help_tags() end, {})
    end
  }
  use {
    'ggandor/leap.nvim',
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, '<tab>', '<Plug>(leap-forward)')
      vim.keymap.set({ 'n', 'x', 'o' }, '<S-tab>', '<Plug>(leap-backward)')
      vim.keymap.set({ 'n', 'x', 'o' }, '<leader><tab>', '<Plug>(leap)')
      vim.keymap.set('n', 'g<tab>', '<Plug>(leap-from-window)')
    end,
  }
  use 'nvim-lua/plenary.nvim'
  use {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
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

      require("harpoon").setup {
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
      }
    end,
  }
  use "christoomey/vim-tmux-navigator"
  use {
    "nvim-treesitter/nvim-treesitter-context",
    config = function() require("treesitter-context").setup() end,
  }
  use "farmergreg/vim-lastplace"
  use {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup {
        columns = { "permissions", "mtime", "size", "icon" },
        constrain_cursor = "name",
        default_file_explorer = true,
        keymaps = {
          ["!"] = "actions.open_terminal",
        },
        view_options = { show_hidden = true },
      }
      vim.keymap.set("n", "<C-e>", "<cmd>Oil<CR>", { noremap = true, desc = "Open parent directory" })
    end,
  }
  use {
    "numToStr/FTerm.nvim",
    config = function()
      local fterm = require("FTerm")
      fterm.setup {
        border = "double",
      }
      vim.api.nvim_create_user_command('FTermOpen', fterm.open, { bang = true })
      vim.api.nvim_create_user_command('FTermClose', require('FTerm').close, { bang = true })
      vim.api.nvim_create_user_command('FTermToggle', require('FTerm').toggle, { bang = true })
      -- FIXME: conflicts with :tabnext binding
      --vim.keymap.set(
      --  "n", "gt", require('FTerm').toggle,
      --  { noremap = true, desc = "Open a terminal in the current directory" }
      --)
    end,
  }
  use {
    'Mathijs-Bakker/zoom-vim',
    config = function()
      vim.keymap.set("n", "<C-w>z", "<Plug>Zoom", { noremap = true })
    end,
  }
end

function M.config()
  -- Shortcuts for navigating between windows
  --vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
  --vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
  -- lsp-zero attempts to map <C-k> to show signature, overwritten here
  --vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
  --vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })

  vim.keymap.set('n', '+', '<C-w>+', { noremap = true })
  vim.keymap.set('n', '-', '<C-w>-', { noremap = true })
end

return M
