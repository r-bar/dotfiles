local Utils = require('utils')
CONFIG = Utils.Config:new()

require('package_manager').load_package_manager()

-- Each entry is expected to export an instance of utils.Config
CONFIG:add(require('base'))
CONFIG:add(require('syntax'))
CONFIG:add(require('colors'))
--CONFIG:add(require('airline'))
-- must be loaded after colors module
CONFIG:add(require('lualine-config'))
CONFIG:add(require('ide'))
CONFIG:add(require('tmux'))
CONFIG:add(require('lsp'))
CONFIG:add(require('treesitter'))
CONFIG:add(require('python'))
CONFIG:add(require('web'))
CONFIG:add(require('haskell'))
CONFIG:add(require('rust'))
CONFIG:add(require('vimwiki'))

CONFIG:init()

return CONFIG
