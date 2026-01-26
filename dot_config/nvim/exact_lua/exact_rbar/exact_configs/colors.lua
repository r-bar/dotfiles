-- All configuration for colorschemes and theming

---@type ConfigPkg
local M = {}

function M.packages(use)
	use({
		"folke/tokyonight.nvim",
		enabled = false,
		config = function()
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	})

	use({
		"shaunsingh/nord.nvim",
		enabled = false,
		config = function()
			require("nord").set()
		end,
	})

	use({
		"EdenEast/nightfox.nvim",
		enabled = true,
		opts = {
			options = {
				transparent = false,
				dim_inactive = true,
			},
		},
		config = function(_plugin, opts)
			require("nightfox").setup(opts)
			vim.cmd([[colorscheme nightfox]])
		end,
	})
end

return M
