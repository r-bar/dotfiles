local M = {}
local Config = {}
-- expose Package as a global configuration primitive
Package = {}

function pformat(thing, indent, _level)
  local output_indent = 0
  local indent_str = ' '
  indent = indent or 0
  _level = _level or 0

  while string.len(indent_str) < (indent * _level) do
    indent_str = indent_str .. ' '
    output_indent = output_indent + 1
  end

  local output = ''

  if type(thing) == 'table' then
    if indent > 0 then
      output = output .. '{\n'
    else
      output = output .. '{'
    end
    for k, v in pairs(thing) do
      output = output .. indent_str .. k .. ' = ' .. pformat(v, indent, _level + 1) .. ';'
      if indent > 0 then
        output = output .. '\n'
      end
    end
    if indent > 0 then
      output = output .. indent_str .. '}\n'
    else
      output = output .. indent_str .. '}'
    end
    return output
  elseif type(thing) == 'string' then
    return string.format("'%s'", thing)
  else
    return string.format('%s', thing)
  end
end

function pprint(thing, indent)
  print(pformat(thing, indent))
end

function M.run(command)
  local handle = require('io').popen(command)
  local result = handle:read("*a")
  local exitcode = handle:close()
  return result, exitcode
end


function M.data_home()
  if vim.env.XDG_DATA_HOME then
    return vim.env.XDG_DATA_HOME .. '/nvim'
  else
    return vim.env.HOME .. '/.local/share/nvim'
  end
end


function M.echom(...)
  vim.cmd(string.format("echom '%s'", string.format(...)))
end


-- implementation details sourced from
-- https://github.com/junegunn/vim-plug/issues/912#issuecomment-559973123


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


function Config:new()
  local new = {
    packages = {};
    configs = {};
    lsp_server_callbacks = {};
    lsp_servers = {};
  }
  self.__index = self
  return setmetatable(new, self)
end

function Config:init(path)

  self:_plug_up(path)
  --self:_pack_up()
  for _, package in ipairs(self.packages) do
    package:configure()
  end
  for _, config in ipairs(self.configs) do
    config()
  end
  -- only load lspconfig module after packages have been initialized
  self:_lsp_init()
end

function Config:_plug_up(path)
  if path == nil then
    vim.fn["plug#begin"]()
  else
    vim.fn["plug#begin"](path)
  end
  for _, package in ipairs(self.packages) do
    package:plug_up()
  end
  vim.fn["plug#end"]()
end

function Config:_pack_up()
  vim.cmd('packloadall')
  for _, package in ipairs(self.packages) do
    package:pack_up()
  end
  -- Currently .discover() does not do anything to manage package dependencies
  -- resulting in errors when we try to load all packages sequentially this way.
  for _, package in ipairs(Package.discover()) do
    package:pack_up()
  end
end

function Config:_lsp_init()
  local lspconfig = require 'lspconfig'
  local lsp = require 'lsp'
  for _, func in ipairs(self.lsp_server_callbacks) do
    local initialize_success, err = xpcall(lsp.initialize, debug.traceback, func)
    if not initialize_success then
      print(err)
    else
      for server, base_args in pairs(lsp.initialize(func)) do
        if self.lsp_servers[server] ~= nil then
          error(string.format("%s language server configured twice", server))
        end
        self.lsp_servers[server] = lsp.merge_args(base_args)
      end
    end
  end
  for server, args in pairs(self.lsp_servers) do
    lspconfig[server].setup(args)
  end
end

-- Config modules ex
function Config:add(module)
  if module.packages ~= nil then
    vim.list_extend(self.packages, module.packages)
    --for i=1, #module.packages do
    --  self.packages[#self.packages + 1] = module.packages[i]
    --end
  end

  if module.config ~= nil then
    self.configs[#self.configs + 1] = module.config
  end

  if module.lsp_callback ~= nil then
    self.lsp_server_callbacks[#self.lsp_server_callbacks + 1] = module.lsp_callback
  end
end

function string.strip(s, char)
  char = char or "%s"
  return s:match("^"..char.."*(.-)"..char.."*$")
end

function string.split(s, sep)
  sep = sep or "%s"
  local output = {}
  local pat = "[^"..sep.."]+"
  for part in string.gmatch(s, pat) do
    output[#output + 1] = part
  end
  return output
end


M.Config = Config
M.Package = Package
return M
