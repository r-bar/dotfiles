local M = {}

function M.packages(use)
	use 'folke/tokyonight.nvim'
end

function M.config()
	vim.cmd[[colorscheme tokyonight-night]]
end

return M
