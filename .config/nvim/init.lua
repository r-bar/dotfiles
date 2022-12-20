require("package_manager").load_package_manager()
local Utils = require("utils")
local Config = require("config").Config
CONFIG = Config:new()


-- Order is not arbitrary. There are some dependencies that are implictly solved
-- by the order
CONFIG:add(require("settings.base"))
CONFIG:add(require("settings.syntax"))
CONFIG:add(require("settings.colors"))
CONFIG:add(require("settings.lualine-config"))
CONFIG:add(require("settings.ide"))
CONFIG:add(require("settings.nav"))
CONFIG:add(require("settings.snippets"))
CONFIG:add(require("settings.treesitter"))
CONFIG:add(require("settings.python"))
CONFIG:add(require("settings.web"))
CONFIG:add(require("settings.haskell"))
CONFIG:add(require("settings.rust"))
CONFIG:add(require("settings.lua"))
CONFIG:add(require("settings.vimwiki"))
-- added last so that lsp.use calls happen before .setup()
CONFIG:add(require("settings.lsp-zero"))

CONFIG:init()

return CONFIG
