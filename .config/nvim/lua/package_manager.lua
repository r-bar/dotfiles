local Utils = require('utils')
local M = {}
Package = {}

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

function Package:new(args)
  local new = {
    enabled = true;
  }
  for k, v in pairs(args) do new[k] = v end
  new.url = args[1]
  if new.name == nil then
    new.name = self.derive_name_from_url(new[1])
  end
  self.__index = self
  return setmetatable(new, self)
end

function Package:configure()
  if self.enabled and self.config ~= nil then
    self.config()
  end
end

function Package:plug_up()
  local options = self:options()
  if self.enabled then
    vim.fn["plug#"](self.url)
  end
  --if options == nil then
  --  vim.fn["plug#"](self[1])
  --else
  --  vim.fn["plug#"](self[1], options)
  --end
end

function Package.derive_name_from_url(repo_url)
  local repo_name = nil
  for match in string.gmatch(repo_url, "[^/]+") do
    repo_name = match
  end

  local suffix_index = #repo_name - 3
  if string.sub(repo_name, suffix_index) == '.git' then
    repo_name = string.sub(repo_name, 1, suffix_index - 1)
  end
  return repo_name
end

-- Return a list of packages from listing a directory. Useful with the neovim
-- pack/*/opt folders
function Package.discover(directory)
  directory = directory or vim.env.HOME .. '/.local/share/nvim/site/pack/base/opt'
  local package_dirs, success = M.run('ls -1 '..directory)
  if not success then
    error(string.format("Could not list %s contents for package discovery", directory))
  end
  package_dirs = string.split(package_dirs, '\n')
  for i, d in ipairs(package_dirs) do
    package_dirs[i] = Package.from_directory(string.strip(d))
  end
  return package_dirs
end

-- Return a Package object representing a given package directory
function Package.from_directory(dir, options)
  local url = nil
  options = nil or {}
  local parts = dir:split()
  local name = parts[#parts]
  -- TODO: could be slow
  --local output, returncode = M.run('git -C '..dir..' remote get-url origin')
  --if returncode == 0 then
  --  url = output:strip()
  --end
  options = vim.tbl_extend('keep', options, {url, name = name, dir = dir})
  return Package:new(options)
end

function Package:pack_up()
  if self.enabled then
    vim.cmd('packadd '..self.name)
  end
end

function Package:options()
  local option_names = {
    'branch';
    'tag';
    'commit';
    'rtp';
    'dir';
    'as';
    'do';
    'on';
    'for';
    'frozen';
  }
  local output = {}
  for _, attr in ipairs(option_names) do
    if self[attr] ~= nil then
      output[attr] = self[attr]
    end
  end
  return output
end

M.Package = Package

return M
