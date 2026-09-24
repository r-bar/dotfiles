-- Configuration for core treesitter providers

---@class ConfigPkg
local M = {}

---Ensure all available tree-sitter parsers are installed and up-to-date.
---Cleans up orphaned parsers that were dropped from nvim-treesitter's registry.
---@param selected_parsers string[]? list of parser language names to ensure are installed (optional)
---@return nil
function M.ensure_parsers(selected_parsers)
	local timeout = nil
	local selected_parsers = selected_parsers or {}

	local ts = require("nvim-treesitter")
	local installed = ts.get_installed()

	-- Clean up orphaned parsers (installed but removed from nvim-treesitter registry)
	local installed_set = {}
	for _, lang in ipairs(selected_parsers) do
		installed_set[lang] = true
	end
	local orphaned = vim.tbl_filter(function(lang)
		return not installed_set[lang]
	end, installed)
	if #orphaned > 0 then
		vim.notify(
			"Uninstalling tree-sitter parsers dropped from nvim-treesitter: " .. table.concat(orphaned, ", "),
			vim.log.levels.WARN
		)
		local parser_dir = require("nvim-treesitter.config").get_install_dir("parser")
		local query_dir = require("nvim-treesitter.config").get_install_dir("queries")
		for _, lang in ipairs(orphaned) do
			local parser_file = vim.fs.joinpath(parser_dir, lang) .. ".so"
			local query_path = vim.fs.joinpath(query_dir, lang)
			pcall(vim.fn.delete, parser_file)
			pcall(vim.fn.delete, query_path, "rf")
		end
	end

	-- Install missing parsers
	local to_install = vim.tbl_filter(function(lang)
		return not vim.list_contains(installed, lang)
	end, selected_parsers)
	if #to_install > 0 then
		ts.install(to_install):wait(timeout)
	end

	ts.update():wait(timeout)
end

function M.packages(use)
	use({
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		run = ":TSUpdate",
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			-- • {tier}  `(integer?)` Only return languages of specified {tier}
			-- (`1`: stable, `2`: unstable, `3`: unmaintained, `4`: unsupported)
			-- For the current support list see:
			-- https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/refs/heads/main/SUPPORTED_LANGUAGES.md
			local available_parsers = {}
			vim.list_extend(available_parsers, ts.get_available(1)) -- stable
			vim.list_extend(available_parsers, ts.get_available(2)) -- unstable
			vim.list_extend(available_parsers, ts.get_available(3)) -- unmaintained
			M.ensure_parsers(available_parsers)

			-- Build filetype list from all available parsers
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
