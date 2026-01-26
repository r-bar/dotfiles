-- Config module for IDE like editing features.

local M = {}

function M.packages(use)
	use({
		"https://github.com/bennypowers/splitjoin.nvim",
		branch = "main",
		config = function()
			local splitjoin = require("splitjoin")
			vim.keymap.set("n", "gj", splitjoin.split, { noremap = true, desc = "Split the object under the cursor" })
			vim.keymap.set("n", "gJ", splitjoin.join, { noremap = true, desc = "Join the object under the cursor" })
		end,
	})

	use({
		"https://github.com/windwp/nvim-autopairs.git",
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
			local npairs = require("nvim-autopairs")
			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")
			npairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string" }, -- it will not add a pair on that treesitter node
					javascript = { "template_string" },
					java = false, -- don't check treesitter on java
				},
			})
			npairs.add_rules({
				Rule("`", "`"):with_pair(cond.not_filetypes({ "ocaml", "rust" })),
				Rule("'", "'"):with_pair(cond.not_filetypes({ "ocaml", "rust" })),
				Rule("(*", "*", "ocaml"):with_move(cond.none()),
			})
		end,
	})

	use({
		"mattn/emmet-vim",
		--enabled = false,
		ft = { "html", "liquid", "eruby", "typescript", "javascript", "reason", "jinja.html" },
		init = function()
			vim.g.user_emmet_leader_key = "<C-e>"
			vim.g.user_emmet_install_global = 1
			vim.g.emmet_html5 = 1
		end,
	})

	use({
		"https://github.com/scrooloose/nerdcommenter.git",
		keys = {
			{ "<leader>cc", "<Plug>NERDCommenterComment", mode = { "n", "v" }, noremap = true },
			{ "<leader>cc", "<Plug>NERDCommenterComment", mode = { "n", "v" }, noremap = true },
			{ "<leader>c", "<Plug>NERDCommenterToEOL", mode = { "n", "v" }, noremap = true },
			{ "<leader>c<space>", "<Plug>NERDCommenterToggle", mode = { "n", "v" }, noremap = true },
			{ "<leader>cA", "<Plug>NERDCommenterAppend", mode = { "n", "v" }, noremap = true },
			{ "<leader>ca", "<Plug>NERDCommenterAltDelims", mode = { "n", "v" }, noremap = true },
			{ "<leader>cb", "<Plug>NERDCommenterAlignBoth", mode = { "n", "v" }, noremap = true },
			{ "<leader>ci", "<Plug>NERDCommenterInvert", mode = { "n", "v" }, noremap = true },
			{ "<leader>cl", "<Plug>NERDCommenterAlignLeft", mode = { "n", "v" }, noremap = true },
			{ "<leader>cm", "<Plug>NERDCommenterMinimal", mode = { "n", "v" }, noremap = true },
			{ "<leader>cn", "<Plug>NERDCommenterNested", mode = { "n", "v" }, noremap = true },
			{ "<leader>cs", "<Plug>NERDCommenterSexy", mode = { "n", "v" }, noremap = true },
			{ "<leader>cu", "<Plug>NERDCommenterUncomment", mode = { "n", "v" }, noremap = true },
			{ "<leader>cy", "<Plug>NERDCommenterYank", mode = { "n", "v" }, noremap = true },
			{ "<leader>c<space>", "<Plug>NERDCommenterToggle", mode = { "n", "v" }, noremap = true },
			{ "<leader>cb", "<Plug>NERDCommenterAlignBoth", mode = { "n", "v" }, noremap = true },
			{ "<leader>ci", "<Plug>NERDCommenterInvert", mode = { "n", "v" }, noremap = true },
			{ "<leader>cl", "<Plug>NERDCommenterAlignLeft", mode = { "n", "v" }, noremap = true },
			{ "<leader>cm", "<Plug>NERDCommenterMinimal", mode = { "n", "v" }, noremap = true },
			{ "<leader>cn", "<Plug>NERDCommenterNested", mode = { "n", "v" }, noremap = true },
			{ "<leader>cs", "<Plug>NERDCommenterSexy", mode = { "n", "v" }, noremap = true },
			{ "<leader>cu", "<Plug>NERDCommenterUncomment", mode = { "n", "v" }, noremap = true },
			{ "<leader>cy", "<Plug>NERDCommenterYank", mode = { "n", "v" }, noremap = true },
		},
		config = function()
			vim.g.NERDCustomDelimiters = {
				kdl = { left = "//", leftAlt = "/*", rightAlt = "*/" },
				mojo = { left = "# " },
				gleam = { left = "// ", leftAlt = "/// " },
			}
		end,
	})

	use({
		"https://github.com/junegunn/vim-easy-align.git",
		keys = {
			{ "ga", "<Plug>(EasyAlign)", mode = "n", noremap = false, desc = "Align text by delimiters" },
			{ "ga", "<Plug>(EasyAlign)", mode = "x", noremap = false, desc = "Align text by delimiters" },
		},
	})

	use({
		"andrewferrier/debugprint.nvim",
		opts = {
			keymaps = {
				normal = {
					plain_below = "g?p",
					plain_above = "g?P",
					variable_below = "g?v",
					variable_above = "g?V",
					variable_below_alwaysprompt = "",
					variable_above_alwaysprompt = "",
					surround_plain = "g?sp",
					surround_variable = "g?sv",
					surround_variable_alwaysprompt = "",
					textobj_below = "g?o",
					textobj_above = "g?O",
					textobj_surround = "g?so",
					toggle_comment_debug_prints = "",
					delete_debug_prints = "",
				},
				insert = {
					plain = "<C-G>p",
					variable = "<C-G>v",
				},
				visual = {
					variable_below = "g?v",
					variable_above = "g?V",
				},
			},
		},
	})
end

return M
