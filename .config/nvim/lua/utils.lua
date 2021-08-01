local M = {}


function M.run(command)
  local handle = require('io').popen(command)
  local result = handle:read("*a")
  handle:close()
  return result
end


function M.data_home()
  if vim.env.XDG_DATA_HOME then
    return vim.env.XDG_DATA_HOME .. '/nvim'
  else
    return vim.env.HOME .. '/.local/share/nvim'
  end
end

-- implementation details sourced from
-- https://github.com/junegunn/vim-plug/issues/912#issuecomment-559973123

Package = {}

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


local Config = {}

function Config:new()
  local new = {
    packages = {};
    config = function() end;
    more_configs = {};
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
  self.config()
  for _, config in ipairs(self.more_configs) do
    config()
  end
end

function Config:add(other)
  for i=1, #other.packages do
    self.packages[#self.packages + 1] = other.packages[i]
  end
  self.more_configs[#self.more_configs + 1] = other.config
end

M.Config = Config


return M
