local loader = require('loader')

loader.load 'rbar/base'
loader.load 'rbar/colors'
loader.load 'rbar/lualine'
loader.load 'rbar/treesitter'
loader.load 'rbar/syntax'
loader.load 'rbar/nav'
loader.load 'rbar/ft_python'
loader.load 'rbar/gitsigns'
loader.load 'rbar/lsp'
loader.load 'rbar/tui'

vim.g.python3_host_prog = vim.env.NVIM_PYTHON or '/usr/bin/python3'

loader.init()
