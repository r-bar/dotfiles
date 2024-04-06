M = {}


function M.packages(use)
  use {
    'ibhagwan/fzf-lua',
    enabled = true,
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
      local fzf = require("fzf-lua")
      vim.keymap.set("n", "<Leader>t", ":FzfLua files<Enter>", { silent = true })
      vim.keymap.set("n", "<Leader>b", ":FzfLua buffers<Enter>", { silent = true })
      vim.keymap.set("n", "<Leader>h", ":FzfLua command_history<Enter>", { silent = true })
      vim.keymap.set("n", "<leader>j", ":FzfLua btags<Enter>", { silent = true })
      vim.keymap.set("n", "<leader>s", ":FzfLua lsp_document_symbols<Enter>", { silent = true })
      vim.keymap.set("n", "<leader>a", ":FzfLua lsp_code_actions<Enter>", { silent = true })
      vim.keymap.set("v", "<leader>a", ":FzfLua lsp_code_actions<Enter>", { silent = true })
      vim.api.nvim_create_user_command("Help", function() fzf.help_tags() end, {})
    end
  }
  use {
    'ggandor/leap.nvim',
    config = function()
      vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
      vim.keymap.set('n', 'gs', '<Plug>(leap-from-window)')
    end,
  }
  use 'nvim-lua/plenary.nvim'
  use {
    'ThePrimeagen/harpoon',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
      local mark  = require("harpoon.mark")
      local ui  = require("harpoon.ui")

      vim.keymap.set("n", "<leader>m", mark.add_file)
      vim.keymap.set("n", "<leader>o", ui.nav_next)
      vim.keymap.set("n", "<leader>i", ui.nav_prev)
      vim.keymap.set("n", "<leader>p", ui.toggle_quick_menu, {noremap = true})
      vim.keymap.set("n", "<C-p>", ui.toggle_quick_menu, {noremap = true})

      vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, {noremap = true})
      vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, {noremap = true})
      vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, {noremap = true})
      vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, {noremap = true})

      vim.keymap.set("n", "<C-1>", function() ui.nav_file(1) end, {noremap = true})
      vim.keymap.set("n", "<C-2>", function() ui.nav_file(2) end, {noremap = true})
      vim.keymap.set("n", "<C-3>", function() ui.nav_file(3) end, {noremap = true})
      vim.keymap.set("n", "<C-4>", function() ui.nav_file(4) end, {noremap = true})

      require("harpoon").setup{
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
