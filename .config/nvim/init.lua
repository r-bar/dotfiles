local Utils = require('utils')
local Config = require('config').Config
CONFIG = Config:new()

require('package_manager').load_package_manager()

CONFIG:add(require('settings.base'))
CONFIG:add(require('settings.syntax'))
CONFIG:add(require('settings.colors'))
CONFIG:add(require('settings.lualine-config'))
CONFIG:add(require('settings.ide'))
CONFIG:add(require('settings.lsp'))
CONFIG:add(require('settings.treesitter'))
CONFIG:add(require('settings.python'))
CONFIG:add(require('settings.web'))
CONFIG:add(require('settings.haskell'))
CONFIG:add(require('settings.rust'))
CONFIG:add(require('settings.vimwiki'))

CONFIG:init()

return CONFIG
