local M = {}

function M.packages(use)
	use 'nvim-lualine/lualine.nvim'
	use 'kyazdani42/nvim-web-devicons'
end

function M.config()
	require('lualine').setup{
		options = { theme = 'tokyonight' }
	}
end

return M
