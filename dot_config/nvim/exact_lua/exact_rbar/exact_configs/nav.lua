---@type ConfigPkg
M = {}

local function open_floating_terminal()
	local oil = require("oil")
	local fterm = require("FTerm")
	---@diagnostic disable-next-line: param-type-mismatch
	local start_dir = vim.fn.chdir(oil.get_current_dir())
	---@diagnostic disable-next-line: missing-fields
	fterm.scratch({})
	vim.fn.chdir(start_dir)
end

function M.packages(use)
	use({
		"ibhagwan/fzf-lua",
		enabled = true,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local fzf = require("fzf-lua")
			vim.keymap.set("n", "<Leader>t", fzf.files, { silent = true, desc = "FzF files" })
			vim.keymap.set("n", "<Leader>b", fzf.buffers, { silent = true, desc = "FzF buffers" })
			vim.keymap.set("n", "<Leader>fb", fzf.buffers, { silent = true, desc = "FzF buffers" })
			vim.keymap.set(
				"n",
				"<leader>fe",
				fzf.diagnostics_workspace,
				{ silent = true, desc = "FzF LSP workspace diagnostics" }
			)
			vim.keymap.set(
				"n",
				"<leader>w",
				fzf.lsp_workspace_symbols,
				{ silent = true, desc = "FzF LSP workspace symbols" }
			)
			vim.keymap.set(
				"n",
				"<leader>fw",
				fzf.lsp_workspace_symbols,
				{ silent = true, desc = "FzF LSP workspace symbols" }
			)
			vim.keymap.set(
				"n",
				"<leader>s",
				fzf.lsp_document_symbols,
				{ silent = true, desc = "FzF LSP document symbols" }
			)
			vim.keymap.set(
				"n",
				"<leader>fs",
				fzf.lsp_document_symbols,
				{ silent = true, desc = "FzF LSP document symbols" }
			)
			vim.keymap.set("n", "<Leader>fc", fzf.command_history, { silent = true, desc = "FzF command history" })
			vim.keymap.set("n", "<leader>fj", fzf.btags, { silent = true, desc = "FzF buffer tags" })
			vim.keymap.set("n", "<leader>fk", fzf.keymaps, { silent = true, desc = "FzF keymaps" })
			vim.keymap.set("n", "<leader>fh", fzf.help_tags, { silent = true, desc = "FzF help tags" })
			vim.keymap.set(
				{ "n", "v" },
				"<leader>a",
				fzf.lsp_code_actions,
				{ silent = true, desc = "FzF code actions" }
			)
			vim.api.nvim_create_user_command("Help", fzf.help_tags, { desc = "FzF search help" })
			fzf.setup()
			fzf.register_ui_select()
		end,
	})
	use({
		"ggandor/leap.nvim",
		keys = {
			{ "s", "<Plug>(leap-forward)", mode = "n", desc = "Leap forward", noremap = true },
			{ "S", "<Plug>(leap-backward)", mode = "n", desc = "Leap backward", noremap = true },
			{ "gs", "<Plug>(leap-from-window)", mode = "n", desc = "Leap from window", noremap = true },
			{ "<space>", "<Plug>(leap)", mode = "n", desc = "Leap in buffer", noremap = true },
			{ "s", "<Plug>(leap-forward)", mode = "x", desc = "Leap forward", noremap = true },
			{ "S", "<Plug>(leap-backward)", mode = "x", desc = "Leap backward", noremap = true },
			{ "gs", "<Plug>(leap-from-window)", mode = "x", desc = "Leap from window", noremap = true },
			{ "<space>", "<Plug>(leap)", mode = "x", desc = "Leap in buffer", noremap = true },
			{ "s", "<Plug>(leap-forward)", mode = "o", desc = "Leap forward", noremap = true },
			{ "S", "<Plug>(leap-backward)", mode = "o", desc = "Leap backward", noremap = true },
			{ "gs", "<Plug>(leap-from-window)", mode = "o", desc = "Leap from window", noremap = true },
			{ "<space>", "<Plug>(leap)", mode = "o", desc = "Leap in buffer", noremap = true },
		},
	})
	use("nvim-lua/plenary.nvim")
	use({
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
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
			local ui = require("harpoon.ui")

			vim.keymap.set("n", "<leader>m", mark.add_file, { noremap = true, desc = "Harpoon add file" })
			vim.keymap.set("n", "<leader>o", ui.nav_next, { noremap = true, desc = "Harpoon next file" })
			vim.keymap.set("n", "<leader>i", ui.nav_prev, { noremap = true, desc = "Harpoon prev file" })
			vim.keymap.set("n", "<leader>p", ui.toggle_quick_menu, { noremap = true, desc = "Harpoon show UI" })
			vim.keymap.set("n", "<C-p>", ui.toggle_quick_menu, { noremap = true, desc = "Harpoon show UI" })

			vim.keymap.set("n", "<leader>1", function()
				ui.nav_file(1)
			end, { noremap = true, desc = "Harpoon show file 1" })
			vim.keymap.set("n", "<leader>2", function()
				ui.nav_file(2)
			end, { noremap = true, desc = "Harpoon show file 2" })
			vim.keymap.set("n", "<leader>3", function()
				ui.nav_file(3)
			end, { noremap = true, desc = "Harpoon show file 3" })
			vim.keymap.set("n", "<leader>4", function()
				ui.nav_file(4)
			end, { noremap = true, desc = "Harpoon show file 4" })

			vim.keymap.set("n", "<A-1>", function()
				ui.nav_file(1)
			end, { noremap = true, desc = "Harpoon show file 1" })
			vim.keymap.set("n", "<A-2>", function()
				ui.nav_file(2)
			end, { noremap = true, desc = "Harpoon show file 2" })
			vim.keymap.set("n", "<A-3>", function()
				ui.nav_file(3)
			end, { noremap = true, desc = "Harpoon show file 3" })
			vim.keymap.set("n", "<A-4>", function()
				ui.nav_file(4)
			end, { noremap = true, desc = "Harpoon show file 4" })
		end,
	})
	use("christoomey/vim-tmux-navigator")

	use({
		"nvim-treesitter/nvim-treesitter-context",
		opts = true,
	})

	use("farmergreg/vim-lastplace")

	use({
		"stevearc/oil.nvim",
		cmd = "Oil",
		-- Disable lazy loading to allow Oil to fully replace netrw
		lazy = false,
		keys = {
			{ "<leader>d", "<cmd>Oil<CR>", mode = "n", noremap = true, desc = "Open parent directory" },
		},
		opts = {
			columns = { "permissions", "mtime", "size", "icon" },
			constrain_cursor = "name",
			default_file_explorer = true,
			skip_confirm_for_simple_edits = true,
			-- default keymaps conflict with my custom window navigation shortcuts
			use_default_keymaps = false,
			keymaps = {
				--["!"]     = "actions.open_terminal",
				["!"] = { open_floating_terminal, mode = "n" },
				["<F5>"] = "actions.refresh",
				["<C-r>"] = "actions.refresh",
				["g?"] = { "actions.show_help", mode = "n" },
				["<CR>"] = "actions.select",
				["gv"] = { "actions.select", opts = { vertical = true } },
				["gh"] = { "actions.select", opts = { horizontal = true } },
				["gt"] = { "actions.select", opts = { tab = true } },
				["gp"] = "actions.preview",
				["<C-c>"] = { "actions.close", mode = "n" },
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["~"] = { "actions.cd", opts = { scope = "win" }, mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["gx"] = "actions.open_external",
				["g."] = { "actions.toggle_hidden", mode = "n" },
				["g\\"] = { "actions.toggle_trash", mode = "n" },
				["q"] = { "actions.close", mode = "n" },
			},
			view_options = { show_hidden = true },
		},
	})

	use({
		"numToStr/FTerm.nvim",
		cmd = { "FTermOpen", "FTermClose", "FTermToggle" },
		opts = {
			border = "double",
		},
		config = function()
			local fterm = require("FTerm")
			vim.api.nvim_create_user_command("FTermOpen", fterm.open, { bang = true })
			vim.api.nvim_create_user_command("FTermOpenParent", function()
				local file_parent = vim.fs.dirname(vim.fn.expand("%"))
				require("FTerm").run({ "cd", file_parent })
			end, { bang = true })
			vim.api.nvim_create_user_command("FTermClose", fterm.close, { bang = true })
			vim.api.nvim_create_user_command("FTermToggle", fterm.toggle, { bang = true })
		end,
	})

	use({
		"Mathijs-Bakker/zoom-vim",
		keys = {
			{ "<C-w>z", "<Plug>Zoom", mode = "n", desc = "Zoom window", noremap = true },
		},
	})

	use({
		"folke/which-key.nvim",
		-- currently only using this plugin for detecting conflicting keymaps using
		-- `:checkhealth which-key`
		enabled = false,
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	})
end

function M.config()
	vim.keymap.set("n", "+", "<C-w>+", { noremap = true })
	vim.keymap.set("n", "-", "<C-w>-", { noremap = true })
end

return M
