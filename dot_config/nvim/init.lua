local loader = require("rbar/loader")

loader.load("rbar/configs/base")
loader.load("rbar/configs/editing")
loader.load("rbar/configs/colors")
loader.load("rbar/configs/statusline")
loader.load("rbar/configs/treesitter")
loader.load("rbar/configs/syntax")
loader.load("rbar/configs/nav")
loader.load("rbar/configs/git")
loader.load("rbar/configs/lsp")
loader.load("rbar/configs/completion")
loader.load("rbar/configs/tui")

vim.g.python3_host_prog = vim.env.NVIM_PYTHON or "/usr/bin/python3"

loader.init()
