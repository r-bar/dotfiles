local Utils = require('utils')
local M = {}


-- automatically configure and download package manager if it is not yet installed
function M.load_package_manager(reinstall)
  vim.g.plug_home = Utils.data_home() .. '/plugged'

  local plug_path = Utils.data_home() .. '/site/autoload/plug.vim'
  local plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if reinstall or not vim.fn.filereadable(plug_path) then
    Utils.run(string.format([[sh -c 'curl -sfLo %s --create-dirs %s']], plug_path, plug_url))
    vim.cmd([[echom 'Vim plugged installed!']])
  end

  local docs_path = Utils.data_home() .. '/site/doc/plug.txt'
  local docs_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/doc/plug.txt'
  if reinstall or not vim.fn.filereadable(docs_path) then
    Utils.run(string.format([[sh -c 'curl -sfLo %s --create-dirs %s']], docs_path, docs_url))
  end
end


return M
