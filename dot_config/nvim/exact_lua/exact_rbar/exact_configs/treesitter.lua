-- Configuration for core treesitter providers

---@type ConfigPkg
local M = {}

function M.packages(use)
	use({
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		run = ":TSUpdate",
		build = ":TSUpdate",
		config = function()
			-- • {tier}  `(integer?)` Only return languages of specified {tier} (`1`:
			--           stable, `2`: unstable, `3`: unmaintained, `4`: unsupported)
			-- For the current support list see:
			-- https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/refs/heads/main/SUPPORTED_LANGUAGES.md
			local timeout = nil

			local ts = require("nvim-treesitter")
			local available_parsers = {}
			vim.list_extend(available_parsers, ts.get_available(1)) -- stable
			vim.list_extend(available_parsers, ts.get_available(2)) -- unstable
			vim.list_extend(available_parsers, ts.get_available(3)) -- unmaintained
			-- vim.list_extend(available_parsers, ts.get_available(4)) -- unsupported

			-- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			-- parser_config.pest = {
			-- 	install_info = {
			-- 		url = "https://github.com/pest-parser/tree-sitter-pest.git", -- local path or git repo
			-- 		files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
			-- 		-- optional entries:
			-- 		branch = "main", -- default branch in case of git repo if different from master
			-- 		generate_requires_npm = false, -- if stand-alone parser without npm dependencies
			-- 		requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
			-- 	},
			-- 	filetype = "pest", -- if filetype does not match the parser name
			-- }
			local installed = ts.get_installed()
			-- print("Available: " .. vim.inspect(available_parsers))
			-- print("Installed: " .. vim.inspect(installed))
			local to_install = vim.tbl_filter(function(lang)
				return not vim.list_contains(installed, lang)
			end, available_parsers)
			if #to_install > 0 then
				-- print("Installing: " .. vim.inspect(to_install))
				ts.install(to_install):wait(timeout)
			end
			ts.update():wait(timeout)

			-- Ensure tree-sitter enabled after opening a file for target language
			local filetypes = {}
			for _, lang in ipairs(available_parsers) do
				for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
					table.insert(filetypes, ft)
				end
			end
			local ts_start = function(ev)
				vim.treesitter.start(ev.buf)
			end

			-- WARN: Do not use "*" here - snacks.nvim is buggy and vim.notify triggers FileType events internally causing infinite callback loops
			vim.api.nvim_create_autocmd("FileType", {
				desc = "Start treesitter",
				group = vim.api.nvim_create_augroup("start_treesitter", { clear = true }),
				pattern = filetypes,
				callback = ts_start,
			})
		end,
		dependencies = {
			"https://github.com/pest-parser/tree-sitter-pest.git",
		},
	})
	use({
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		opts = {
			select = {
				-- Automatically jump forward to textobj, similar to targets.vim
				lookahead = true,
				-- You can choose the select mode (default is charwise 'v')
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * method: eg 'v' or 'o'
				-- and should return the mode ('v', 'V', or '<c-v>') or a table
				-- mapping query_strings to modes.
				selection_modes = {
					["@parameter.outer"] = "v", -- charwise
					["@function.outer"] = "V", -- linewise
					-- ['@class.outer'] = '<c-v>', -- blockwise
				},
				-- If you set this to `true` (default is `false`) then any textobject is
				-- extended to include preceding or succeeding whitespace. Succeeding
				-- whitespace has priority in order to act similarly to eg the built-in
				-- `ap`.
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * selection_mode: eg 'v'
				-- and should return true of false
				include_surrounding_whitespace = false,
			},
		},
	})
end

return M
