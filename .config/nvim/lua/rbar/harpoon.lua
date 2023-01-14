local M = {}
function M.packages(use)
	use {'ThePrimeagen/harpoon', requires = 'nvim-lua/plenary.nvim'}
end

function M.config()
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

	require("harpoon").setup({
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
	})
end
return M
