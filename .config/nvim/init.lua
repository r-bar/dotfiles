local Utils = require('utils')
local Config = Utils.Config:new()

require('package_manager').load_package_manager()

-- Each entry is expected to export an instance of utils.Config
Config:add(require('base'))
Config:add(require('syntax'))
Config:add(require('colors'))
Config:add(require('airline'))
Config:add(require('ide'))
Config:add(require('tmux'))
Config:add(require('lsp'))
--Config:add(require('treesitter'))
Config:add(require('python'))
Config:add(require('web'))
Config:add(require('haskell'))
Config:add(require('rust'))
Config:add(require('vimwiki'))

--print(vim.inspect(Config.packages))

--Config:init(Utils.data_home() .. '/plugged')
Config:init()
