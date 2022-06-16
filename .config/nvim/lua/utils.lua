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
    vim.fn["plug#"](self[1])
  end
  --if options == nil then
  --  vim.fn["plug#"](self[1])
  --else
  --  vim.fn["plug#"](self[1], options)
  --end
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
  if path == nil then
    vim.fn["plug#begin"]()
  else
    vim.fn["plug#begin"](path)
  end
  for _, package in ipairs(self.packages) do
    package:plug_up()
  end
  vim.fn["plug#end"]()

  for _, package in ipairs(self.packages) do
    package:configure()
  end

  for _, config in ipairs(self.configs) do
    config()
  end

  -- only load lspconfig module after packages have been initialized
  local lspconfig = require 'lspconfig'
  local lsp = require 'lsp'
  for _, func in ipairs(self.lsp_server_callbacks) do
    for server, base_args in pairs(lsp.initialize(func)) do
      if self.lsp_servers[server] ~= nil then
        error(string.format("%s language server configured twice", server))
      end
      self.lsp_servers[server] = lsp.merge_args(base_args)
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


M.Config = Config
M.Package = Package
return M
