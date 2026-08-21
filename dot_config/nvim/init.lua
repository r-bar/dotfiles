local loader = require("rbar/loader")
local env = require("rbar/environment")

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
loader.load("rbar/configs/agentic")

vim.g.python3_host_prog = env.PYTHON or "/usr/bin/python3"

loader.init()
